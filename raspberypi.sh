
sudo faillog -m 3 -l 3600

sudo apt-get -o Acquire::ForceIPv4=true update
sudo apt-get -o Acquire::ForceIPv4=true upgrade

sudo apt-get -y -o Acquire::ForceIPv4=true install hostapd dnsmasq tcpdump openvpn

echo '\n' >> /etc/dhcpcd.conf
echo 'denyinterfaces wlan0' >> /etc/dhcpcd.conf

sudo cp interfaces /etc/network/
sudo cp hostapd.conf /etc/hostapd/
sudo cp hostapd /etc/default/

sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
sudo cp dnsmasq.conf /etc/

sudo cp ca.crt /etc/openvpn/client/
sudo cp client.crt /etc/openvpn/client/
sudo cp client.key /etc/openvpn/client/

#add running on startup /etc/rc.local
sudo openvpn --config /etc/openvpn/client/client.ovpn

# uncomment line net.ipv4.ip_forward=1

sudo iptables -A POSTROUTING -o tun0 -t nat -j MASQUERADE  
sudo iptables -A FORWARD -i tun0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o tun0 -j ACCEPT
sudo iptables -P FORWARD DROP

sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-request -s 192.168.0.0/16 -j ACCEPT

sudo iptables -A INPUT -p udp -i wlan0 --dport 53 -j ACCEPT
sudo iptables -A INPUT -p udp -i wlan0 --dport 67 -j ACCEPT
sudo iptables -A INPUT -p udp -i eth0 -j ACCEPT

sudo iptables -A INPUT -p tcp -i wlan0 ! -d 192.168.0.0/16 -j ACCEPT
sudo iptables -A INPUT -p tcp -i eth0 --dport 22 -s 192.168.0.0/16 -j ACCEPT
sudo iptables -A INPUT -p tcp -i eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

sudo iptables -A INPUT -p tcp -i tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT

sudo iptables -P INPUT DROP

sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

# /etc/rc.local
# iptables-restore < /etc/iptables.ipv4.nat 

sudo reboot





# https://hallard.me/raspberry-pi-read-only/
# https://learn.sparkfun.com/tutorials/setting-up-a-raspberry-pi-3-as-an-access-point/all

