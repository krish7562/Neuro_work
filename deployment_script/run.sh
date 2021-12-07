#!/bin/sh

python3 create_db.py

# start qms nodejs
if [[ $APP_NAME == "qms_node" ]]
then
    echo "starting qms node apps"
     # start qms web app
     git clone git@bitbucket.org:panasonicinnovationcenter/qms_web_app.git

    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "git clone failed"
        exit 1
    fi

    cp .env qms_web_app/panasonic/.env
    cp create_admin.js qms_web_app/panasonic/create_admin.js
    cd qms_web_app/panasonic

    npm install

    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "npm install failed"
        exit 1
    fi

    pm2 start server.js
    # create admin user
    echo "waiting for admin user creation"
    sleep 2m
    node create_admin.js
    
    cd ../../
    
    # start qms api nodejs
    git clone git@bitbucket.org:panasonicinnovationcenter/qms_api.git

    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "git clone failed"
        exit 1
    fi

    # start qms_api
    cp .env qms_api/.env
    cd qms_api

    npm install

    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "npm install failed"
        exit 1
    fi

    pm2 start server_api.js
    cd ..
    
    # customer booking angular app
    echo "starting customer booking angular"
    ng analytics off

    # git clone git@bitbucket.org:panasonicinnovationcenter/qms_web_app.git

    #retVal=$?
    #if [ $retVal -ne 0 ]; then
     #   echo "git clone failed"
     #   exit 1
    #fi

    # start qms_web_app
    cp .env qms_web_app/panasonic_angular/.env
    cd qms_web_app/panasonic_angular

    npm install
    
    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "npm install failed"
        exit 1
    fi

    ng serve --host 0.0.0.0 --port 44959

fi



# start kiosk booking angular
if [[ $APP_NAME == "kiosk" ]]
then
    echo "starting kiosk booking angular"
    ng analytics off
    git clone git@bitbucket.org:panasonicinnovationcenter/kiosk.git

    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "git clone failed"
        exit 1
    fi

    # start kiosk
    cp .env kiosk/.env
    cd kiosk

    npm install
    
    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "npm install failed"
        exit 1
    fi

    ng serve --host 0.0.0.0 --port 44956
fi


# start pwa booking angular
if [[ $APP_NAME == "pwa" ]]
then
    echo "starting pwa angular"
    ng analytics off
    git clone git@bitbucket.org:panasonicinnovationcenter/pwa.git

    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "git clone failed"
        exit 1
    fi

    cp .env pwa/.env
    cd pwa

    npm install
    
    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "npm install failed"
        exit 1
    fi

    ng build --prod && http-server -p 8081 -c-1 dist/customer-pwa
fi






