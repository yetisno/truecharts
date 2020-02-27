iocage exec tautulli service tautulli stop
iocage exec tautulli pkg update -y && pkg upgrade -y
iocage exec tautulli cd /usr/local/share/Tautulli
iocage exec tautulli git pull
iocage exec tautulli chown -R tautulli:tautulli /usr/local/share/Tautulli /config
iocage exec tautulli cp /usr/local/share/Tautulli/init-scripts/init.freenas /usr/local/etc/rc.d/tautulli
iocage exec tautulli chmod u+x /usr/local/etc/rc.d/tautulli
iocage exec tautulli service tautulli start