iocage exec radarr service radarr stop
iocage exec radarr pkg update && pkg upgrade -y
iocage exec radarr "fetch https://github.com/Radarr/Radarr/releases/download/v0.2.0.1480/Radarr.develop.0.2.0.1480.linux.tar.gz -o /usr/local/share"
iocage exec radarr "tar -xzvf /usr/local/share/Radarr.develop.0.2.0.1480.linux.tar.gz -C /usr/local/share"
iocage exec radarr rm /usr/local/share/Radarr.develop.0.2.0.1480.linux.tar.gz
iocage exec radarr chown -R radarr:radarr /usr/local/share/Radarr /config
cp ../includes/radarr-conf/radarr.rc /mnt/tank/iocage/jails/radarr/root/usr/local/etc/rc.d/radarr
iocage exec radarr chmod u+x /usr/local/etc/rc.d/radarr
iocage exec radarr service radarr start