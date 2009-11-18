# run_mode:
#   - normal: nothing special (*default*)
#   - itk: apache is running with the itk module
#          and run_uid and run_gid are used as vhost users
# run_uid: the uid the vhost should run as with the itk module
# run_gid: the gid the vhost should run as with the itk module
define apache::vhost::php::safe_mode_bin(
   $path
){
    $substr=regsubst($name,'^.*\/','','G')
    $real_path = "$path/$substr"
    link{ "$real_path":
         target => regsubst($name,'^.*_','')
    }
}

