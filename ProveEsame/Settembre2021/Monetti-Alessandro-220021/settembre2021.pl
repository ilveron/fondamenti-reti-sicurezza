#!/usr/bin/perl

my @netstat = qx(netstat -tupan);

my %ip_num;

foreach(@netstat){
    chomp;
    if($_ =~ /tcp\s+\S+\s+\S+\s+([0-9\.]+?):(\d+)\s+\S+\s+ESTABLISHED.*/){
        $ip = $1;
        $port = $2;
        if($ip ne "127.0.0.1" && $port == 80){
            if(exists $ip_num{$ip}){
                ++$ip_num{$ip};
            }
            else{
                $ip_num{$ip} = 1;
            }
        }
    }
}

foreach $ip (keys %ip_num){
    $connNumber = $ip_num{$ip};
    qx(iptables -t nat -A PREROUTING -d $ip -p tcp --dport 80 -j DNAT --to 10.0.7.15:8000) if($connNumber > 3);
}

# iptables -t nat -A PREROUTING -d 192.168.1.107 -p tcp --dport 80 -j DNAT --to 10.0.7.15:8000