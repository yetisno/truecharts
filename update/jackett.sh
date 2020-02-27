iocage exec jackett service jackett stop
iocage update jackett
iocage exec jackett "pkg update && pkg upgrade -y"
iocage exec jackett "fetch https://github.com/Jackett/Jackett/releases/download/v0.11.502/Jackett.Binaries.Mono.tar.gz -o /usr/local/share"
iocage exec jackett "tar -xzvf /usr/local/share/Jackett.Binaries.Mono.tar.gz -C /usr/local/share"
iocage exec jackett rm /usr/local/share/Jackett.Binaries.Mono.tar.gz
iocage exec jackett chown -R jackett:jackett /usr/local/share/Jackett /config
cp ../includes/jackett-conf/jackett.rc /mnt/tank/iocage/jails/jackett/root/usr/local/etc/rc.d/jackett
iocage exec jackett chmod u+x /usr/local/etc/rc.d/jackett
iocage exec jackett service jackett start