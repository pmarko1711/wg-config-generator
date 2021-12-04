#!/bin/bash

# be sure to have this file to be in .gitignore

EXPORT_DIR="export"

if [ $# -gt 1 ]; then
    echo "Illegal number of parameters, either no or only one argument accepted"  1>&2
    exit 1
fi

if [ $# -eq 1 ]; then
    # process only one specific config
    if [[ $1 == ${EXPORT_DIR}/* ]]; then
        file_conf=${1#/$EXPORT_DIR}
        echo $file_conf
    else
        file_conf=$EXPORT_DIR/$1
    fi
    if [ ! -f $file_conf ]; then
        echo "File $file_conf does not exist" 1>&2
        exit 1
    else
        echo 
        echo "Generating QR code for $file_conf" 
        qrencode -t ANSIUTF8 < $file_conf     
    fi
else
    # process all exported configs
    echo 
    echo "Generating QR codes"
    for file_conf in $EXPORT_DIR/*.conf
    do
        echo "  Exporting $f to ${file_conf}.png"
        qrencode -t PNG -o ${file_conf}.png < $file_conf
    done
fi

