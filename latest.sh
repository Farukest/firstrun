ltst=/home/latest_packet_forwarder
if [ -d "$ltst" ]; then
	echo 'latest_packet_forwarder KLASORU SILINIYOR ...'
	rm -rf /home/latest_packet_forwarder
fi

cd /home && git clone https://github.com/Farukest/latest_packet_forwarder.git

chmod 777 /home/latest_packet_forwarder/*.sh


FILE=/home/latest_packet_forwarder/sx1302_hal/Makefile
if [ -e "$FILE" ]; then
	echo "Makefile exist so may compiled c and obj.. check and remove them.."
	
	# Check pktfwd exist
	PKTFWD=/home/latest_packet_forwarder/sx1302_hal/packet_forwarder/lora_pkt_fwd
	if [ -e "$PKTFWD" ]; then
		echo "PKTFWD REMOVED.."
		rm -rf /home/latest_packet_forwarder/sx1302_hal/packet_forwarder/lora_pkt_fwd
	fi 

	# check obj .o exist
	PKTFWDOBJ=/home/latest_packet_forwarder/sx1302_hal/packet_forwarder/obj/lora_pkt_fwd.o
	if [ -e "$PKTFWDOBJ" ]; then
		echo "PKTFWD .o REMOVED.."
		rm -rf /home/latest_packet_forwarder/sx1302_hal/packet_forwarder/obj/lora_pkt_fwd.o
	fi 
				
	echo "Making new PKTFWD files and the OBJ .o files.."
	# Create new pktfwd and the obj .o					
	cd /home/latest_packet_forwarder/sx1302_hal/ && make -f Makefile
	echo "Making files success.."
	
	
	echo "Maked files moving and keeping and transferring.."
	# Move pktfwd to to tmp and then remove folders and again move pktfwd to folder
	mv /home/latest_packet_forwarder/sx1302_hal/packet_forwarder/lora_pkt_fwd /tmp/
	rm -rf /home/latest_packet_forwarder/sx1302_hal
	mkdir -p /home/latest_packet_forwarder/sx1302_hal/packet_forwarder/
	mv /tmp/lora_pkt_fwd /home/latest_packet_forwarder/sx1302_hal/packet_forwarder/  
	echo "Transferring success.."
fi   



docker stop miner && docker rm miner

i2c_value_num=0
i2c_value=i2c-$i2c_value_num

reffolder=/root/minereferance
if [ -d "$reffolder" ]; then
	echo $reffolder
	echo 'REF KLASORU SILINIYOR ...' $reffolder
	rm -rf $reffolder
fi

crontab -r
{ crontab -l; echo ""; } | crontab -

cd /root && git clone https://github.com/Farukest/minereferance.git minereferance
chmod 700 /root/minereferance/configs/sys.config

#root pi hnt miner altındaki referans alınan sys.configi replace edilebilen dosya
chmod 700 /root/minereferance/configs/sys.config
sed -i 's/"replace_i2c_value"/"'${i2c_value}'"/g' /root/minereferance/configs/sys.config
sed -i 's/replace_i2c_value/'${i2c_value}'/g' /root/minereferance/configs/setting.toml
# sed -i 's/1680/'${docker_miner_start_port}'/g' /root/minereferance/configs/setting.toml


docker run -d --init --ulimit nofile=64000:64000 --restart always --net host -e OTP_VERSION=23.3.4.7 -e REBAR3_VERSION=3.16.1 --name miner \
-e args_name=miner \
--mount type=bind,source=/home/pi/hnt/miner,target=/var/data \
--mount type=bind,source=/home/pi/hnt/miner/log,target=/var/log/miner --device /dev/i2c-0  --privileged -v /var/run/dbus:/var/run/dbus \
--mount type=bind,source=/home/pi/hnt/miner/configs/sys.config,target=/config/sys.config \
--mount type=bind,source=/root/minereferance/configs/setting.toml,target=/etc/helium_gateway/settings.toml \
--mount type=bind,source=/root/minereferance/configs/setting.toml,target=/opt/gateway-rs/settings.toml \
quay.io/team-helium/miner:gateway-latest

sleep 1

echo '----------------------------'
echo 'SUCCESS THAT IS ALL..'
echo '----------------------------'


sleep 2

echo '----------------------------'
echo '----------------------------'
echo '----------------------------'
echo "................ LORA BAŞLATILIYOR ................"
echo '----------------------------'
echo '----------------------------'
echo '----------------------------'

crontab -r
{ crontab -l; echo ""; } | crontab -


echo 'Jobs adding to cron..'
cd /home/latest_packet_forwarder/ && ./addcron.sh
