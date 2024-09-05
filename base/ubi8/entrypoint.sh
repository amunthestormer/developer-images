#!/bin/bash

source kubedock_setup

set -e

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

if ! grep -Fq "${USER_ID}" /etc/passwd; then
    # current user is an arbitrary 
    # user (its uid is not in the 
    # container /etc/passwd). Let's fix that 

    # sed -e "s/\${USER_ID}/${USER_ID}/g" \
    # -e "s/\${GROUP_ID}/${GROUP_ID}/g" \
    # -e "s/\${HOME}/\/home\/user/g" \
    # /.passwd.template > /etc/passwd   
    echo "user:x:${USER_ID}:${GROUP_ID}:user:${HOME}:/bin/bash" > /etc/passwd
    
    # sed -e "s/\${USER_ID}/${USER_ID}/g" \
    #     -e "s/\${GROUP_ID}/${GROUP_ID}/g" \
    #     -e "s/\${HOME}/\/home\/user/g" \
	# /.group.template > /etc/group
    echo "user:x:${USER_ID}:${GROUP_ID}" > /etc/group
fi

exec "$@"
