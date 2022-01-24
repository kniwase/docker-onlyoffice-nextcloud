# Easy way to install Nextcloud with ONLYOFFICE Document Server

## Requirements

* The latest version of Docker
* Docker compose
* Nginx server


## Installation

1. Get the latest version of this repository running the command:

    ```
    git clone https://github.com/ONLYOFFICE/docker-onlyoffice-nextcloud
    cd docker-onlyoffice-nextcloud
    ```

1. Create the directory named as `core-fonts` in the project folder and locate font files you want to use in ONLYOFFICE to `core-fonts`:

    **Please note**: In order to update  with **root** rights.

    ```
    docker-compose up -d
    ```

1. Run Docker Compose:

    **Please note**: the action must be performed with **root** rights.

    ```
    docker-compose up -d
    ```

    **Please note**: you might need to wait a couple of minutes when all the containers are up and running after the above command.

1. Go to the project folder and run the `set_configuration.sh` script. Enter all the necessary data to complete the wizard:

    **Please note**: the action must be performed with **root** rights.

    Wizard Sample
    ```
    Enter the admin user name: admin
    Enter the admin password: 
    Confirm the admin password: 
    Enter your domain: nextcloud.example.com
    Enter root directory of nextcloud (default: /): /subdirectory/
    Use https? (Y/n): 
    --------------------
    [Config]
    admin user name: admin
    admin password: ** masked **
    Your Nextcloud url: https://nextcloud.example.com/subdirectory/
    --------------------
    Is this OK? (y/N): y
    ```

1. Add the server directive for Nextcloud and ONLYOFFICE in `/etc/nginx/nginx.conf` and restart the nginx daemon:

    **Please note**: the sample bellow should be adjusted according to your environment.

    ```
    server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name nextcloud.example.com;
        
        # for ssl
        ssl_certificate /path/to/ssl/certificate;
        ssl_certificate_key /path/to/ssl/certificate_key;

        proxy_set_header Host $host;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Connection $connection_upgrade;
        
        location = /.well-known/carddav { return 301 /subdirectory/remote.php/dav; }
        location = /.well-known/caldav { return 301 /subdirectory/remote.php/dav; }
        location = /.well-known/webfinger { return 301 /subdirectory/index.php/.well-known/webfinger; }
        location = /.well-known/nodeinfo { return 301 /subdirectory/index.php/.well-known/nodeinfo; }

        rewrite ^/subdirectory(.*) $1 break;
        location / { proxy_pass http://localhost:28081; }
    }
    ```

1. Launch the browser and enter the webserver address.

Now you can enter Nextcloud and create a new document. It will be opened in ONLYOFFICE Document Server.
