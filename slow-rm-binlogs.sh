#!/bin/bash

usage(){
    echo "Usage: $0 filename1 filename2
######### this will remove file from filename1 to filename2 slowly"
    exit 1
}

# invoke  usage
# call usage() function if filename not supplied
[[ $# -ne 2 ]] && usage

sfile=$1
efile=$2
filename=$1
purgefile=$2

get_next() {
    num=`echo $filename | awk -F. '{print $2}' | grep -o '[^0].*' `
    prefix=`echo $filename | awk -F. '{print $1}'`
    let "num+=1"
    len=${#num}
    if [ $len -lt 6 ];then
        zs=""
        for((i=1;i<=`expr 6 - $len`;i++));do
            zs=${zs}"0"
        done
        num=${zs}${num}
    fi
    filename=${prefix}"."
    filename=${filename}${num}
}

run() {
    for((j=0;;j++));do
        if [ ! -f "$filename" ];then
           echo "file $filename Not exists"
           exit 1
        fi
        filenames[${#filenames[@]}]=$filename
        if [ "$filename" = "$efile" ];then
            get_next
            purgefile=$filename
            break;
        fi
        get_next
    done

    echo "The following files will be removed:"

    i=0
    for element in "${filenames[@]}"; do
      echo "$element"
      let "i+=1"
    done

    while true;do
      read -p "Do you wish to remove the $i files above(yes/no)?" yn
      case $yn in
        [Yy]* ) remove_files; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
      esac
    done

    echo "$i binary log files have been removed."
    echo "Execute the following command in MySQL:"
    echo "======================================"
    echo "mysql> purge binary logs to $purgefile"
    echo "======================================"
}

remove_files(){
    for element in "${filenames[@]}"; do
      sleep 2
      echo "removing file $element"
      nice -n 19 rm $element
    done
}

run

