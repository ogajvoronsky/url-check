#!/bin/bash
# Alex Haivoronsky

DESTINATION='url-check-results.csv'
red=`tput setaf 1`
green=`tput setaf 2`
nc=`tput sgr0`

print_help() {
   echo "${red}USAGE:${nc} url-check.sh -s url_filename [-d output_filename] "
   echo "       url_filename - list of url's to check"
   echo "       output_filename - output csv-file (optional)"
}


while test -n "$1"; do
  case "$1" in
  --help|-h)
    print_help
    exit
    ;;
#   --version|-v)
#     print_version $PROGNAME $VERSION
#     exit
#     ;;
  --source|-s)
    if [[ -z $2 || ! -r $2 ]]; then 
        echo "Cannot read source file: $2"
        print_help
        exit
    fi
    SOURCE=$2
    shift
    ;;
  --destination|-d)
    if [[ -n $2 ]]; then 
        DESTINATION=$2
    fi 
    shift
    ;;
  *)
    echo "Unknown argument: $1"
    print_help
    exit
    ;;
  esac
  shift
done

if [[ -z $SOURCE ]]; then 
    print_help
    exit 
fi


rm -f $DESTINATION

check_url() {
    url=`echo $url | awk '{ print $1 }' | tr -d '\n'` # truncate and remove newlines
    res=$(curl -s -o /dev/null -w "%{http_code}" ${url})

    case $res in 
    301|302)
        echo "${url},${res},$(curl -s -o /dev/null -w "%{redirect_url}" ${url})" >> $DESTINATION 
        ;;
    200|40[1-4]|503)
        echo "${url},${res}" >> $DESTINATION
        ;;
    *)
        ;;
    esac 
}

readarray urls < $SOURCE

array_size=${#urls[@]}
element_number=0

for url in "${urls[@]}" 
do
    ((element_number++))
    echo -ne "Progress: ${element_number}/${array_size}... \r"
    check_url
done

