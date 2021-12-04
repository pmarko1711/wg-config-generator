#!/bin/bash

# make sure to have this FILE_KEYS and EXPORT_DIR files and directory in .gitignore

FILE_KEYS="keys"
EXPORT_DIR="export"
PREFIX_PUBLIC="KEY_PUBLIC_"
PREFIX_PRIVATE="KEY_PRIVATE_"
PREFIX_PRESHARED="KEY_PRESHARED_"

declare -a KEYS_PUBLIC
declare -a KEYS_PRIVATE
declare -a KEY_CORES
declare -a KEYS_PRESHARED
declare -a KEYS_ALL
declare -a GENKEYS_PUBLIC
declare -a GENKEYS_PRIVATE
declare -a GENKEYS_PRESHARED

if [ -f $FILE_KEYS ]; then
    echo "Loading the existing keys from $FILE_KEYS"
    source $FILE_KEYS
else
    echo "File with keys does not exist yet, will be generated"
fi


echo "Identifying required keys in config files"
# find all the keys
for f in *.conf
do
  echo "  Processing $f"
  # do something on $
  keys=($(sed -n "s/^.*<\([A-Za-z0-9_]*\).*$/\1/p" $f))
  for key in "${keys[@]}"
  do
    # public keys
    if [[ $key == ${PREFIX_PUBLIC}* ]] ; then
        if [[ ! " ${KEYS_PUBLIC[*]} " =~ " ${key} " ]]; then
            KEYS_PUBLIC[${#KEYS_PUBLIC[@]}]=$key
        fi

        core=${key#$PREFIX_PUBLIC}
        if [[ ! " ${KEY_CORES[*]} " =~ " ${core} " ]]; then
            KEY_CORES[${#KEY_CORES[@]}]=$core
        fi
    fi
    # private keys
    if [[ $key == ${PREFIX_PRIVATE}* ]] ; then
        if [[ ! " ${KEYS_PRIVATE[*]} " =~ " ${key} " ]]; then
            KEYS_PRIVATE[${#KEYS_PRIVATE[@]}]=$key
        fi

        core=${key#$PREFIX_PRIVATE}
        if [[ ! " ${KEY_CORES[*]} " =~ " ${core} " ]]; then
            KEY_CORES[${#KEY_CORES[@]}]=$core
        fi
    fi

    # sharedkeys
    if [[ $key == ${PREFIX_PRESHARED}* ]] ; then
        if [[ ! " ${KEYS_PRESHARED[*]} " =~ " ${key} " ]]; then
            KEYS_PRESHARED[${#KEYS_PRESHARED[@]}]=$key
        fi
    fi
  done
done


# all keys
KEYS_ALL=("${KEYS_PUBLIC[@]}" "${KEYS_PRIVATE[@]}" "${KEYS_PRESHARED[@]}")


echo
echo "Configs contain the following keys"
echo "  Private keys: ${KEYS_PRIVATE[*]}"
echo "  Public keys: ${KEYS_PUBLIC[*]}"
echo "  Preshared keys: ${KEYS_PRESHARED[*]}"

echo
echo "Generating keys"
for core in ${KEY_CORES[@]}
do
    key_private="${PREFIX_PRIVATE}${core}"
    key_public="${PREFIX_PUBLIC}${core}"
    if [ ! -z ${!key_private+x} ] && [ -z ${!key_public+x} ]; then
        echo
        echo "ERROR: $key_private exists but $key_public does not" 1>&2
        exit 1
    elif [ ! -z ${!key_public+x} ] && [ -z ${!key_private+x} ]; then
        echo "Error!" 1>&2
        echo "ERROR: $key_public exists but $key_private does not" 1>&2
        exit 1
    elif [ ! -z ${!key_private+x} ] && [ ! -z ${!key_public+x} ]; then
        echo "  Pair $key_public and $key_private exists already, skipping"
    else
        #echo "  Pair $key_public and $key_private does not exist yet, will be generated"
        echo "  $key_private" 
        private_key_value=`wg genkey`
        declare "$key_private=$private_key_value"
        echo "${key_private}=${!key_private}" >> $FILE_KEYS
        echo "  $key_public" 
        public_key_value=`echo "$private_key_value" | wg pubkey`
        declare "$key_public=$public_key_value"
        echo "${key_public}=${!key_public}" >> $FILE_KEYS
    fi
done
for key in ${KEYS_PRESHARED[@]};
do
    if [ ! -z ${!key+x} ]; then
        echo "  Preshared key $key already exists" 
    else
        echo "  $key"
        preshared_key_value=`wg genpsk`
        declare "$key=$preshared_key_value"
        echo "${key}=${!key}" >> $FILE_KEYS
    fi
done

# finally, modify the files
mkdir -p $EXPORT_DIR
echo
echo "Generating actual configs"
for f in *.conf
do
  echo "  Exporting $f"
  cp $f $EXPORT_DIR
  for key in "${KEYS_ALL[@]}"; do
    escaped_key=$(printf '%s\n' "${!key}" | sed -e 's/[\/&]/\\&/g')
    sed -i "s/<$key>/${escaped_key}/" $EXPORT_DIR/$f
  done
done