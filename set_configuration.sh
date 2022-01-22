#!/bin/bash
while :
do
    read -p "Enter the admin user name: " admin_username
    if [ "$admin_username" != "" ]; then
        break
    fi
done
while :
do
    read -sp "Enter the admin password: " admin_password
    echo
    read -sp "Confirm the admin password: " admin_password_confirm
    echo
    if [ "$admin_password" = "$admin_password_confirm" ]; then
        break
    elif [ "$admin_password" = "" ] || [ "$admin_password_confirm" = "" ]; then
        echo "Bad password: no characters in password."
    else
        echo "Passwords do not match."
    fi
done
while :
do
    read -p "Enter your domain: " server_domain
    if [ "$server_domain" != "" ]; then
        break
    fi
done
read -p "Enter root directory of nextcloud (default: /): " root_directory
if [ "$root_directory" = "" ]; then
    root_directory="/"
fi
while :
do
    read -p "Use https? (Y/n): " ans
    if [ "$ans" = "y" ] || [ "$ans" = "" ]; then
        protocol="https"
        break
    elif [ "$ans" = "n" ]; then
        protocol="http"
        break
    fi
done

url="$protocol://$server_domain$root_directory"
dosrvpath="ds-vpath/"
dosrvurl="$url$dosrvpath"

echo "--------------------"
echo "[Config]"
echo "admin user name: $admin_username"
echo "admin password: ** masked **"
echo "Your Nextcloud url: $url"
echo "--------------------"
while :
do
    read -p "Is this OK? (y/N): " ans
    if [ "$ans" = "y" ] || [ "$ans" = "" ]; then
        echo
        break
    elif [ "$ans" = "n" ]; then
        exit 1
    fi
done

echo "Start configuring Nextcloud"

docker-compose exec -u www-data app php occ maintenance:install \
    --database="pgsql" \
    --database-name="nextcloud" \
    --database-host="nextcloud-db" \
    --database-user="nextcloud" \
    --database-pass="nextcloud" \
    --admin-user="$admin_username" \
    --admin-pass="$admin_password"

docker-compose exec -u www-data app php occ config:system:set trusted_domains 1 --value="$server_domain"
docker-compose exec -u www-data app php occ config:system:set overwritehost --value="$server_domain"
docker-compose exec -u www-data app php occ config:system:set overwriteprotocol --value="$protocol"
docker-compose exec -u www-data app php occ config:system:set overwritewebroot --value="$root_directory"
docker-compose exec -u www-data app php occ config:system:set overwrite.cli.url --value="$url"

docker-compose exec -u www-data app php occ --no-warnings app:install onlyoffice
docker-compose exec -u www-data app php occ --no-warnings config:system:set onlyoffice DocumentServerUrl --value="$dosrvurl"
docker-compose exec -u www-data app php occ --no-warnings config:system:set onlyoffice DocumentServerInternalUrl --value="http://onlyoffice-document-server/"
docker-compose exec -u www-data app php occ --no-warnings config:system:set onlyoffice StorageUrl --value="http://nginx-server/"
docker-compose exec -u www-data app php occ --no-warnings config:system:set allow_local_remote_servers --value=true

echo "Nextcloud was successfully configured!"

exit 0
