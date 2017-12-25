#!/bin/bash

CONTAINER=$1

for i in $(ps -ef | grep $(docker inspect --format '{{.State.Pid}}' $CONTAINER) | awk '{print $2}') ;
do
    grep NSpid: /proc/$i/status | awk '{ print $2 " " $3}';
done
