iocage exec organizr service nginx stop
iocage exec organizr service php-fpm stop
iocage exec organizr pkg update -y && pkg upgrade -y
mv /mnt/tank/iocage/jails/organizr/root/usr/local/etc/nginx/nginx.conf /mnt/tank/iocage/jails/organizr/root/usr/local/etc/nginx/nginx.conf.bak
cp ../includes/organizr-conf/nginx.conf /mnt/tank/iocage/jails/organizr/root/usr/local/etc/nginx/nginx.conf
cp ../includes/organizr-conf/custom /mnt/tank/iocage/jails/organizr/root/usr/local/etc/nginx/custom
iocage exec tautulli cd /usr/local/www/Organizr
iocage exec organizr git pull
iocage exec organizr chown -R www:www /usr/local/www /config /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/custom
iocage exec organizr service nginx start
iocage exec organizr service php-fpm start