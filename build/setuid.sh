#!/bin/bash

USER_ID=${USER:-999}
GROUP_ID=${GROUP:-999}

groupmod -o -g $USER_ID gamearch
usermod -o -u $GROUP_ID gamearch

echo -e "\nUpdating permissions:\n"
echo -e "USER: $USER_ID\n"
echo -e "GROUP: $GROUP_ID\n"

chown gamearch:gamearch -R /data