# of.xchg.com

AngularJS Yeoman sandbox

Useful commands

    # production uses this for log file when gunicorn is running
    sudo rm -f /home/www-data/www/of4/logs/node.log
    tail /home/www-data/www/of4/logs/node.log

    tail /var/log/nginx/of.xchg.com.error.log
    sudo /usr/sbin/visudo

    # set permissions on logs directory
    sudo chmod -R 666 /home/www-data/www/of4/logs

    ps aux | grep 'forever'
    ps -ef | grep 'forever' | grep -v grep | awk '{print $2}'
    sudo kill -9 `ps -ef | grep 'forever' | grep -v grep | awk '{print $2}'`

    sudo /etc/init.d/nginx restart
    sudo vi /etc/nginx/sites-available/of.xchg.com

    # Mongodb
    # Ubuntu
    tail /var/log/mongodb/mongodb.log 
    sudo rm -f /var/log/mongodb/mongodb.log

    # In Windows, as admin: 

    # To repair
    rm C:\mongodb\data\mongod.lock
    cd C:\mongodb\bin && mongod --repair

    # manual start
    C:\mongodb\bin\mongod.exe --dbpath C:\mongodb\data


    # To install as service
    C:\mongodb\bin\mongod.exe --config C:\mongodb\mongod.cfg --install

    # Start 
    net start MongoDB



## Installation

### MongoDB
    http://www.mongodb.org/downloads
    
##### Ubuntu

    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
    sudo echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | tee -a /etc/apt/sources.list.d/10gen.list
    sudo apt-get -y update
    sudo apt-get -y install mongodb

### Prepare Python Development Environment

Return to previous user

    exit
    # may have to re-source .bashrc
    source .bashrc

    # make sure we are in correct directory
    cd /home/www-data/www/of4

Install required packages

**Ubuntu**
    npm install

Run app on production

    node /home/www-data/www/of4/dist/simplehttpserver.js /home/www-data/www/of4/dist

goto `http://of.xchg.com`
    
### Testing


### Nginx

    # sudo vi /etc/nginx/sites-available/of.xchg.com

    # Add the following

    upstream of_server {
        server 127.0.0.1:2013 fail_timeout=0;
    }

    server {
        listen   80;
        server_name of.xchg.com;
        access_log  /var/log/nginx/of.xchg.com.access.log;
        error_log  /var/log/nginx/of.xchg.com.error.log warn;

        location / {
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $http_host;
                proxy_redirect off;

                proxy_pass   http://of_server;
        }

        location /static {
            root /home/www-data/www/of4/dist;
        }

        location /media {
            root /home/www-data/www/of4/dist;
        }
    }
    server {
        listen   443;
        listen   5002;
        server_name of.xchg.com;
        ssl on;
        ssl_certificate /etc/nginx/ssl/xchg_ssl.crt;
        ssl_certificate_key /etc/nginx/ssl/xchg_ssl.key;

        access_log  /var/log/nginx/of.com.access.log;
        error_log  /var/log/nginx/of.com.error.log;

        location / {
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $http_host;
                proxy_redirect off;

                proxy_pass   http://of_server;
        }

        location /static {
            root /home/www-data/www/of4/dist;
        }

        location /media {
            root /home/www-data/www/of4/dist;
        }
    }
