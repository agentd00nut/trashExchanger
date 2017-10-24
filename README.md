# trashExchanger
Easily upload files to http://trash.exchange/


# Flags:
```
      [-u] upload_path:         Where we should look for images to upload if a single image was not specified.
      [-s] save_response        Should we save the image we received from the trash?
      [-p] save_path:           Where should we save the image we got from the trash?  Defaults to ./responseImages.  Automatically creates path if it doesnt exist
      [-d] dump_mode            Will continually upload the same file forever and saves the response images.  Don't be a jerk with this i guess, idk.
      [-t] title:               Sets the title of your image for when people get it from the trash.  Defaults to a self plug for me because... why not?
      [-o] output_response_url  Dumps the output response URL to STDOUT if set.  Urls are only valid for a very short time.
      [-h]                      output this text
```

#    Usage:
 
Without any flags or arguments the script will automatically attempt to upload all the files from the path it was run from.
It will do this silently... passing "-o" will let you know if it worked or not.
Its not smart enough to only try images!

Passing a single argument will make the script only attempt to upload that one file.

The rest of the flags are fairly self explanatory... Flags with a ":" require an argument. 