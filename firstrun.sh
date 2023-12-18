#!/bin/bash

set +e

FIRSTUSER=`getent passwd 1000 | cut -d: -f1`
FIRSTUSERHOME=`getent passwd 1000 | cut -d: -f6`
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom enable_ssh
else
   systemctl enable ssh
fi
if [ -f /usr/lib/userconf-pi/userconf ]; then
   /usr/lib/userconf-pi/userconf 'farukest' '$5$ysn5dL7i0h$gHTOB4A8BUtRyf7wVMbBEUpc3evo6EFOU.3CGDJikRB'
else
   echo "$FIRSTUSER:"'$5$ysn5dL7i0h$gHTOB4A8BUtRyf7wVMbBEUpc3evo6EFOU.3CGDJikRB' | chpasswd -e
   if [ "$FIRSTUSER" != "farukest" ]; then
      usermod -l "farukest" "$FIRSTUSER"
      usermod -m -d "/home/farukest" "farukest"
      groupmod -n "farukest" "$FIRSTUSER"
      if grep -q "^autologin-user=" /etc/lightdm/lightdm.conf ; then
         sed /etc/lightdm/lightdm.conf -i -e "s/^autologin-user=.*/autologin-user=farukest/"
      fi
      if [ -f /etc/systemd/system/getty@tty1.service.d/autologin.conf ]; then
         sed /etc/systemd/system/getty@tty1.service.d/autologin.conf -i -e "s/$FIRSTUSER/farukest/"
      fi
      if [ -f /etc/sudoers.d/010_pi-nopasswd ]; then
         sed -i "s/^$FIRSTUSER /farukest /" /etc/sudoers.d/010_pi-nopasswd
      fi
   fi
fi
rm -f /boot/firstrun.sh
sed -i 's| systemd.run.*||g' /boot/cmdline.txt
sed 's/^PermitRootLogin\s.*$/PermitRootLogin yes/' sshd_config
exit 0
