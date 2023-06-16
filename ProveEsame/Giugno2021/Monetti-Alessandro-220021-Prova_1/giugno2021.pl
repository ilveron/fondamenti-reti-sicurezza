#!/usr/bin/perl

open(my $fh_log, "<", "/var/log/auth.log") or die $!;

my %ip_tries;

while(<$fh_log>) {
    chomp;
    if($_ =~ /.*?ssh\S\sFailed\spassword\sfor\sroot\sfrom\s(\S+)\s.*/){
        $ip = $1;
        if(exists $ip_tries{$ip}){
            ++$ip_tries{$ip};
        }
        else {
            $ip_tries{$ip} = 1;
        }
    }
}

close $fh_log or die $!;

foreach $key (keys %ip_tries){
    qx(iptables -A INPUT -s $key -p tcp --dport 22 -j DROP) if($ip_tries{$key} > 5);
}