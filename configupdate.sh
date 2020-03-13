#!/bin/sh
TMPDIR=/tmp
rm -rf $TMPDIR/smartdns
mkdir $TMPDIR/smartdns
cd $TMPDIR/smartdns

#Update configuration file
wget --retry-connrefused --waitretry=2 -qO- https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/union.conf | sed 's/=\/./ \//' - | sed 's/0.0.0.0/#/' - > yhosts_union.conf.tmp &
pid1=$!
wget -b --retry-connrefused --waitretry=2 -O yhosts_ip.conf.tmp https://raw.githubusercontent.com/vokins/yhosts/master/dnsmasq/ip.conf
pid2=$!
wget --retry-connrefused --waitretry=2 -qO- https://cokebar.github.io/gfwlist2dnsmasq/dnsmasq_gfwlist.conf | sed 's/127.0.0.1#5353/secure/' - | sed 's/server/nameserver/' - > gfwlist.conf.tmp &
pid3=$!
wget -b --retry-connrefused --waitretry=2 -O googlehosts.conf.tmp https://raw.githubusercontent.com/googlehosts/hosts/master/hosts-files/dnsmasq.conf
pid4=$!
wget -b --retry-connrefused --waitretry=2 -O googlehosts_ipv6.conf.tmp https://raw.githubusercontent.com/googlehosts/hosts-ipv6/master/hosts-files/dnsmasq.conf
pid5=$!
wget -b --retry-connrefused --waitretry=2 -O anti-AD.conf.tmp https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-smartdns.conf
pid6=$!
wait $pid1
wait $pid2
wait $pid3
wait $pid4
wait $pid5
wait $pid6
sed -i '/^#/d' *.conf.tmp
sed -i 's/=/ /' *.conf.tmp
sort -u yhosts_union.conf.tmp anti-AD.conf.tmp > ad.conf.tmp
rename 's/\.tmp$//' *.conf.tmp

wget -b --retry-connrefused --waitretry=2 -O adguard.hosts.tmp https://raw.githubusercontent.com/r-a-y/mobile-hosts/master/AdguardDNS.txt
pid1=$!
wget -b --retry-connrefused --waitretry=2 -O Peter_Lowe.hosts.tmp 'https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&mimetype=plaintext'
pid2=$!
wget --retry-connrefused --waitretry=2 -O malwaredomains.hosts.tmp.1 https://mirror1.malwaredomains.com/files/domains.hosts && awk -F '#' '($1) {print $1}' malwaredomains.hosts.tmp.1 > malwaredomains.hosts.tmp &
pid3=$!
wget --retry-connrefused --waitretry=2 -qO- https://raw.githubusercontent.com/vokins/yhosts/master/hosts.txt | sed '/^@/d' - > yhosts.hosts.tmp &
pid4=$!
wget -b --retry-connrefused --waitretry=2 -O adwars.hosts.tmp https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts
pid5=$!
wget -b --retry-connrefused --waitretry=2 -O neohosts.hosts.tmp 'https://cdn.jsdelivr.net/gh/neoFelhz/neohosts@gh-pages/full/hosts'
pid6=$!
wget -b --retry-connrefused --waitretry=2 -O hphosts.hosts.tmp https://hosts-file.net/ad_servers.txt
pid7=$!
wait $pid1
wait $pid2
wait $pid3
wait $pid4
wait $pid5
wait $pid6
wait $pid7
cat *.hosts.tmp > all.hosts.tmp
dos2unix all.hosts.tmp
sed -i '/^#/d' all.hosts.tmp
sed -i 's/127.0.0.1/#/' all.hosts.tmp
sed -i 's/0.0.0.0/#/' all.hosts.tmp
sed -i 's/::/#/' all.hosts.tmp
sort -u all.hosts.tmp | awk '/^#/ {printf"address /%s/%s\n",$2,$1}' - > all.hosts

rm -f *.tmp wget-log*
tar -cJ -C $TMPDIR -f $TMPDIR/smartdns.tar.xz smartdns
