#!/bin/bash


usage(){
  cat <<EOF
  trashExchanger.sh

    @abrothers656

    Automates sending files to trash.exchange

    Flags:
      [-u] upload_path:         Where we should look for images to upload if a single image was not specified.
      [-s] save_response        Should we save the image we received from the trash?
      [-p] save_path:           Where should we save the image we got from the trash?  Defaults to ./responseImages.  Automatically creates path if it doesnt exist
      [-d] dump_mode            Will continually upload the same file forever and saves the response images.  Don't be a jerk with this i guess, idk.
      [-t] title:               Sets the title of your image for when people get it from the trash.  Defaults to a self plug for me because... why not?
      [-o] output_response_url  Dumps the output response URL to STDOUT if set.  Urls are only valid for a very short time.
      [-h]                      output this text

    Usage:
      Without any flags or arguments the script will automatically attempt to upload all the files from the path it was run from.
        It will do this silently... passing "-o" will let you know if it worked or not.
        Its not smart enough to only try images!

      Passing a single argument will make the script only attempt to upload that one file.

      The rest of the flags are fairly self explanatory... Flags with a ":" require an argument. 
EOF
}

upload_path="./"
save_response="0"
save_path="./responseImages"
dump="0"
output_response_url="0";
title="Twitter: @abrothers656... Tweet at me if you see this"

while getopts ":t:p:u:odsh" opt; do
  case $opt in
    u)
      upload_path=$OPTARG
      ;;
    s)
      save_response="1"
      ;;
    p)
      save_path=$OPTARG
      ;;
    d)
      dump="1"
      save_response="1";
      ;;
    t)
      title=$OPTARG
    ;;
    o)
      output_response_url="1"
    ;;
    h)
      usage;
      exit 1;
    ;;
    \?)
      usage;
      ;;
  esac
done
shift $((OPTIND-1))

if [ ! -d "${save_path}" ]; then
  mkdir -p "${save_path}";
fi

main(){
    f=$1
    ### GET COOKIE AND CSRF ###
    r=$( curl -siL "http://trash.exchange/can" );
    ck=$( echo $r | grep -Eo 'session=.*?;' )
    csrf=$( echo $r | grep -Eo 'csrf_token.*?>' | cut -d '"' -f 7 )

    ### POST THE FILE ###
    x=$( curl -s -iL --request POST \
            --url http://trash.exchange/can \
            --header 'content-type: multipart/form-data; boundary=----WebKitFormBoundary0OiEoWU1tAisGkMB' \
            --cookie "${ck}" \
            --form "csrf_token=${csrf}" \
            --form "file=@${f}" \
            --form "title=${title}" \
            --trace-ascii /dev/stdout | grep -Eo 'https://.*?/>' | cut -d '"' -f1 | sed 's/amp;//g'; );

    if [ "${output_response_url}" = "1" ];then
        echo $x;
    fi

    ### SAVE RESPONSE###
    if [ "${save_response}" = "1" ]; then

        fn=$( echo "${x}" | cut -d "?" -f1 | cut -d "/" -f 4 ) 

        curl -s "${x}" > "${save_path}/"$( echo "${x}" | cut -d "?" -f1 | cut -d "/" -f 4 ) 
    fi;
}


if [ "$dump" = "1" ]; then
    images_fetched=0
    while true; do
        main $1
        images_fetched=$((images_fetched+1))
        echo "${images_fetched}"
        sleep 1;
    done

else
    if [ -z "$1" ]; then
        for f in *; do
            if [ "$f" = "autoTrash.sh" ]; then
              continue;
            fi
            main $f;
        done
    else
      main $1
    fi
fi