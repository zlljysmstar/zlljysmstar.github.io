#Load Modules
modprobe iptable_nat
modprobe ip_conntrack
modprobe ip_conntrack_ftp
modprobe ip_nat_ftp

#
iptables -F
iptables -X
iptables -Z

#Add SNAT Feature
iptables -t nat -A POSTROUTING -o p4pl -s 192.168.0.0/24 -j SNAT --to 192.168.1.202
