#!/bin/bash

if [[ -z $1 ]]; then
    echo 'parameter 1 must be the desired bit bucket repository'
    exit 1
fi
REPOSITORY=$1

if [[ -z $2 ]]; then
    echo 'parameter 2 path to checkout destination'
    exit 1
fi
REPOSITORY_PATH=$2

if [[ -z $3 ]]; then
    echo 'parameter 3 is branch'
    exit 1
fi
BRANCH=$3

#logic below does not work if if path ends in /
LAST_CHAR=${REPOSITORY_PATH: -1}
if [[ $LAST_CHAR = / ]]; then
    echo "REPOSITORY_PATH $REPOSITORY_PATH cannot end with / because below logic fails"
    exit 1
fi

#desired repository checkout name
REPOSITORY_NAME=${REPOSITORY_PATH##*/}
#location of checkout i.e. the path minus /REPOSITORY NAME
REPOSITORY_PATH=${REPOSITORY_PATH%/*}

echo "repository $REPOSITORY is being checked to ${REPOSITORY_PATH}/${REPOSITORY_NAME}"

#do a checkout if repository is checked out... otherwise clone
if [ -d ${REPOSITORY_PATH}/${REPOSITORY_NAME} ]; then
    cd ${REPOSITORY_PATH}/${REPOSITORY_NAME}

    nonsensecommandtoprimestatus >/dev/null 2>&1;
    until [ `echo $?` -eq 0 ]; do sleep 3; git fetch --all; done ;

    git checkout ${BRANCH};
    #default to master if branch does not exist
    if [ 0 != $? ]; then
        BRANCH="master";
        git checkout ${BRANCH};
    fi;

    git reset --hard origin/${BRANCH};

else
    cd ${REPOSITORY_PATH}

    nonsensecommandtoprimestatus >/dev/null 2>&1;
    until [ `echo $?` -eq 0 ]; do
        sleep 3;
        git clone git@bitbucket.org:mnv_tech/${REPOSITORY} ${REPOSITORY_PATH}/${REPOSITORY_NAME}
    done

    cd ${REPOSITORY_PATH}/${REPOSITORY_NAME}
    git checkout ${BRANCH}
    exit 0;
fi
