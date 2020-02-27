iocage exec sonarr service sonarr stop
iocage exec sonarr pkg update -y && pkg upgrade -y
iocage exec sonarr "fetch http://download.sonarr.tv/v2/master/mono/NzbDrone.master.tar.gz -o /usr/local/share"
iocage exec sonarr "tar -xzvf /usr/local/share/NzbDrone.master.tar.gz -C /usr/local/share"
iocage exec sonarr rm /usr/local/share/NzbDrone.master.tar.gz
iocage exec sonarr chown -R sonarr:sonarr /usr/local/share/NzbDrone /config
cp ../includes/sonarr-conf/sonarr.rc /mnt/tank/iocage/jails/sonarr/root/usr/local/etc/rc.d/sonarr
iocage exec sonarr chmod u+x /usr/local/etc/rc.d/sonarr
iocage exec sonarr service sonarr start