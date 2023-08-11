#!/bin/bash

while getopts s:p: option
do
  case "${option}" in
    s) solana=${OPTARG};;
    p) proxy=${OPTARG};;
    *) echo -e "usage: $0 \n [-s] solana container name \n [-p] proxy container name \n" >&2
       exit 1 ;;
  esac
done

request_neon_url="http://127.0.0.1:3333/request_neon"
solana_url="http://127.0.0.1:8899"
evm_loader="53DfF883gyixYNXnM7s5xhdeyV8mVk9T4i2hGV9vG9io"

export accounts_list=("0x1823085af38c56f080922f19d8E34e87e70DD63c" "0xa6dC77C7dF6b5d3AeCDAECc30c056B6FD68FE15d" "0x167691dC492512d8bde0Ee04B61d104983420fec") 
export accounts_private_keys_list=("7efe7d68906dd6fb3487f411aafb8e558863bf1d2f60372a47186d151eae625a" "09fb68d632c2b227cc6da77696de362fa38cb94e1c62d8a07db82e7d5e754f10" "9b6007319e21225003fe120b4d7be1ee447d0fb29f52ca72914dad41fb47ddb9")
len=${#accounts_list[@]}

echo "Create accounts in solana"
for (( i=0; i<$len; i++ ))
do
    request="neon-cli create-ether-account "${accounts_list[$i]}" --url="$solana_url" --evm_loader="$evm_loader""
    echo $request
    docker exec -it $solana /bin/bash -c "$request"
done

echo "Create accounts in proxy"
for (( i=0; i<$len; i++ ))
do
    request="neon-cli create-ether-account "${accounts_list[$i]}" --url="$solana_url" --evm_loader="$evm_loader""
    echo $request
    docker exec -it $solana /bin/bash -c "$request"
done

echo "Requesting neons for accounts"
for (( i=0; i<$len; i++ ))
do
    request="./proxy-cli.sh account import --private-key "${accounts_private_keys_list[$i]}""
    echo $request
    docker exec -it $proxy /bin/bash -c "$request"
done
