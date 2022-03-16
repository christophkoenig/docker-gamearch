#!/bin/bash
echo -e "\nCreating static env file...\n" && \
    cd /app && \
    ./env.sh && \
    cp env-config.js /usr/share/nginx/html
