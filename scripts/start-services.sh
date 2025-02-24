#!/bin/bash

/opt/znuny/bin/Cron.sh start otrs
service cron start
apache2ctl -D FOREGROUND