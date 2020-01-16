#!/bin/sh

IPT=/sbin/iptables
# NAT interface
NIF=enp0s9
# NAT IP address
NIP='10.0.98.100'

# Host-only interface
HIF=enp0s3
# Host-only IP addres
HIP='192.168.60.100'

# DNS nameserver 
NS='10.0.98.3'

# DNS server
#DNS_SERVER='/etc/network/interfaces'

## Reset the firewall to an empty, but friendly state

# Flush all chains in FILTER table
$IPT -t filter -F
# Delete any user-defined chains in FILTER table
$IPT -t filter -X
# Flush all chains in NAT table
$IPT -t nat -F
# Delete any user-defined chains in NAT table
$IPT -t nat -X
# Flush all chains in MANGLE table
$IPT -t mangle -F
# Delete any user-defined chains in MANGLE table
$IPT -t mangle -X
# Flush all chains in RAW table
$IPT -t raw -F
# Delete any user-defined chains in RAW table
$IPT -t mangle -X

# Default policy is to send to a dropping chain
$IPT -t filter -P INPUT DROP
$IPT -t filter -P OUTPUT DROP
$IPT -t filter -P FORWARD DROP


# Create logging chains
$IPT -t filter -N input_log
$IPT -t filter -N output_log
$IPT -t filter -N forward_log

# Set some logging targets for DROPPED packets
$IPT -t filter -A input_log -j LOG --log-level notice --log-prefix "input drop: " 
$IPT -t filter -A output_log -j LOG --log-level notice --log-prefix "output drop: " 
$IPT -t filter -A forward_log -j LOG --log-level notice --log-prefix "forward drop: " 
echo "Added logging"

# Return from the logging chain to the built-in chain
$IPT -t filter -A input_log -j RETURN
$IPT -t filter -A output_log -j RETURN
$IPT -t filter -A forward_log -j RETURN



# These rules must be inserted at the end of the built-in
# chain to log packets that will be dropped by the default
# DROP policy
$IPT -t filter -A INPUT -j input_log
$IPT -t filter -A OUTPUT -j output_log
$IPT -t filter -A FORWARD -j forward_log

# Task 17 Enable traffic from loopback interface
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT
$IPT -A OUTPUT -p tcp --dport 22 -j ACCEPT

#Task 18 Allow ServerA to ping the other interfaces
#$IPT -A OUTPUT -s 192.168.60.100 -p icmp --icmp-type 8 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#echo "add echo ICMP Echo Request..."
#$IPT -A INPUT -d 192.168.60.100 -p icmp --icmp-type 0 -m state --state ESTABLISHED,RELATED -j ACCEPT
#echo "add echo ICMP Echo Reply..."

#Task19 :Allow Server A to ping all host
#$IPT -A OUTPUT -p udp --dport 53 -j ACCEPT
#$IPT -A INPUT -p udp --sport 53 -j ACCEPT
#$IPT -A INPUT -p udp --dport 53 -j ACCEPT
#$IPT -A OUTPUT -p udp --sport 53 -j ACCEPT

#$IPT -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT
#$IPT -A INPUT -p icmp --icmp-type 0 -j ACCEPT
#$IPT -A INPUT -p icmp --icmp-type 8 -j ACCEPT
#$IPT -A OUTPUT -p icmp --icmp-type 0 -j ACCEPT

#Task20:Enable stateful firewall
$IPT -A OUTPUT -p udp --dport 53 -j ACCEPT
$IPT -A INPUT -p udp --sport 53 -j ACCEPT
$IPT -A INPUT -p udp --dport 53 -j ACCEPT
$IPT -A OUTPUT -p udp --sport 53 -j ACCEPT

$IPT -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type 0 -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type 8 -j ACCEPT
$IPT -A OUTPUT -p icmp --icmp-type 0 -j ACCEPT
$IPT -t filter -A INPUT -p tcp -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT
$IPT -t filter -A OUTPUT -p tcp -m conntrack --ctstate NEW,ESTABLISHED,RELATED -j ACCEPT

#Task21:Enable SSH and HTTPS content from apache2 server for web browser on host
$IPT -A INPUT -p tcp -m multiport --dport 22,443 -j ACCEPT 
$IPT -A OUTPUT -p tcp -m multiport --sport 22,443 -j ACCEPT


#Task22:Ping ServerA from ClientA
$IPT -A OUTPUT -s 192.168.60.111 -d 192.168.60.100 -j ACCEPT

#Task26:Change iptables to forward packets

$IPT -t filter -A FORWARD -i $HIF -j ACCEPT
$IPT -t filter -A FORWARD -i $NIF -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

#Task27:Enable SNAT on Server A
$IPT -t nat -A POSTROUTING -j SNAT -o $NIF --to $NIP

















