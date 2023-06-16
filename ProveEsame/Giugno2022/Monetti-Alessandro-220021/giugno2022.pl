#!/usr/bin/perl

while (1==1) {
    my @ifconfig = qx(ifconfig enp1s0) or die $!;
    shift @ifconfig;

    my $ip;

    foreach(@ifconfig){
        chomp;
        $_ =~ /^\s+inet\s+(\S+)\s.*/;
        $ip = $1;
        last if($ip); 
    }

    my @netstat = qx(netstat -tupan);
    my $establishedConn = 0;

    foreach(@netstat) {
        chomp;
        if($_ =~ /^tcp\s+\S+\s+\S+\s+([0-9\.]+)[:\s].*?ESTABLISHED.*/){
            ++$establishedConn if($1 == $ip);
        }
    }

    if($establishedConn > 30){
        qx(iptables -A INPUT -s $ip -i enp1s0 -j DROP);
        qx(iptables -A OUTPUT -s $ip -o enp1s0 -j DROP);
        $ruleGiven = 1;
    }
    elsif($ruleGiven){
        qx(iptables -D INPUT -s $ip -i enp1s0 -j DROP);
        qx(iptables -D OUTPUT -s $ip -o enp1s0 -j DROP);
        $ruleGiven = 0
    }

    sleep(15*60);
}
 