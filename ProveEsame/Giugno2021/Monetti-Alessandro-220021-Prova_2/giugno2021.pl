#!/usr/bin/perl

@netstat = qx(netstat -tn);
shift @netstat; shift @netstat;     # Remove the first two lines

my %ip_num;

foreach(@netstat){
    chomp;
    if($_ =~ /\S+\s+\S+\s+\S+\s+(\S+?):80\s+(\S+?):.*?ESTABLISHED.*/){
        $remote_ip = $2;
        if(exists $ip_num{$remote_ip}){
            ++$ip_num{$remote_ip};
        }
        else {
            $ip_num{$remote_ip} = 1;
        }
    }
}

# Add PREROUTING rule if the number of unique ESTABLISHED connections exceeds the number of 3
qx(iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to 10.0.7.5:8000) if(scalar keys %ip_num > 3);