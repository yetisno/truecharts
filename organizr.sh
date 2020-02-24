echo '{"pkgs":["nginx","php72","php72-filter","php72-curl","php72-hash","php72-json","php72-openssl","php72-pdo","php72-pdo_sqlite","php72-session","php72-simplexml","php72-sqlite3","php72-zip","git","ca_root_nss"]}' > /tmp/pkg.json
iocage create -n "organizr" -p /tmp/pkg.json -r 11.3-RELEASE ip4_addr="vnet0|192.168.10.21/22" defaultrouter="192.168.10.1" vnet="on" allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json
iocage exec organizr mkdir -p /config
iocage fstab -a organizr /mnt/tank/apps/organizr /config nullfs rw 0 0
iocage exec organizr sed -i '' -e 's?listen = 127.0.0.1:9000?listen = /var/run/php-fpm.sock?g' /usr/local/etc/php-fpm.d/www.conf
iocage exec organizr sed -i '' -e 's/;listen.owner = www/listen.owner = www/g' /usr/local/etc/php-fpm.d/www.conf
iocage exec organizr sed -i '' -e 's/;listen.group = www/listen.group = www/g' /usr/local/etc/php-fpm.d/www.conf
iocage exec organizr sed -i '' -e 's/;listen.mode = 0660/listen.mode = 0600/g' /usr/local/etc/php-fpm.d/www.conf
iocage exec organizr cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini
iocage exec organizr sed -i '' -e 's?;date.timezone =?date.timezone = "Universal"?g' /usr/local/etc/php.ini
iocage exec organizr sed -i '' -e 's?;cgi.fix_pathinfo=1?cgi.fix_pathinfo=0?g' /usr/local/etc/php.ini
mv /mnt/tank/iocage/jails/organizr/root/usr/local/etc/nginx/nginx.conf /mnt/tank/iocage/jails/organizr/root/usr/local/etc/nginx/nginx.conf.bak
cp ./organizr-conf/inginx.conf /mnt/tank/iocage/jails/organizr/root/usr/local/etc/nginx/nginx.conf
iocage exec organizr git clone https://github.com/causefx/Organizr.git /usr/local/www/Organizr
iocage exec organizr chown -R www:www /usr/local/www /config
iocage exec organizr ln -s /config/config.php /usr/local/www/Organizr/api/config/config.php
iocage exec organizr sysrc nginx_enable=YES
iocage exec organizr sysrc php_fpm_enable=YES
iocage exec organizr service nginx start
iocage exec organizr service php-fpm start