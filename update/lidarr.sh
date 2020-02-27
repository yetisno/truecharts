iocage exec lidarr service lidarr stop
iocage exec lidarr pkg update -y && pkg upgrade -y
iocage exec lidarr "fetch https://github.com/lidarr/Lidarr/releases/download/v0.2.0.371/Lidarr.develop.0.2.0.371.linux.tar.gz -o /usr/local/share"
iocage exec lidarr "tar -xzvf /usr/local/share/v0.2.0.371/Lidarr.develop.0.2.0.371.linux.tar.gz -C /usr/local/share"
iocage exec lidarr "rm /usr/local/share/v0.2.0.371/Lidarr.develop.0.2.0.371.linux.tar.gz"
iocage exec lidarr chown -R lidarr:lidarr /usr/local/share/Lidarr /config
cp ../includes/lidarr-conf/lidarr.rc /mnt/tank/iocage/jails/lidarr/root/usr/local/etc/rc.d/lidarr
iocage exec lidarr chmod u+x /usr/local/etc/rc.d/lidarr
iocage exec lidarr service lidarr start