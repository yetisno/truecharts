iocage exec plex service plexmediaserver_plexpass stop
iocage update plex
iocage exec plex "pkg update && pkg upgrade -y"
iocage exec plex chown -R plex:plex /usr/local/share/plexmediaserver-plexpass/
iocage exec plex service plexmediaserver_plexpass start
sleep 10s
echo "Waiting 20s to stop plex"
iocage stop plex
sleep 10s
echo "Waiting 20s to start plex"
iocage start plex
iocage exec plex service plexmediaserver_plexpass start
echo "Finished installing plex"