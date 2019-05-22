#!/bin/bash

#set pwd
cd /opt/app/current

#set virtual display
# start xvfb so that tests can be executed in a headless environment
echo "Starting X virtual framebuffer (Xvfb) in background"
Xvfb :10 -screen 0 1600x1200x24 &
export DISPLAY=:10

#echo out environment variables we care about
echo APPLICATION_VARIABLES
echo NODE_ENV=$NODE_ENV
if [ $NODE_ENV == production ] ; then
    echo RUNNING PRODUCTION  UI TESTS
    make test-prod
    cp mochawesome-report/mochawesome.html mochawesome-report/$JOB_NAME.html
    cp mochawesome-report/mochawesome.json mochawesome-report/$JOB_NAME.json
elif [ $NODE_ENV == qa ] ; then
    echo RUNNING QA  UI TESTS
    make test
    cp mochawesome-report/mochawesome.html mochawesome-report/$JOB_NAME.html
    cp mochawesome-report/mochawesome.json mochawesome-report/$JOB_NAME.json
fi