#!/usr/bin/perl

my $rule = "FORWARD -j DROP -s"; 

while(1==1){
    my %mac_ip = ();
    my @toFilter = ();
    my @arp = qx(arp -n);
    shift @arp;

    foreach (@arp){
        chomp;
        $_ =~ /(\S+)\s+\S+\s+(\S+)\s.*/;
        if(exists $mac_ip{$2}){
            @toFilter.push($1);
            @toFilter.push($mac_ip{$2}) if(grep(/^$mac_ip{$2}$/, @toFilter);
        } else {
            $mac_ip{$2} = $1;
        }
    }

    foreach (@toFilter) {
        chomp;
        #qx(iptables -A $rule $_);
    }

    sleep(30*60);
    
    foreach (@toFilter){
        chomp;
        #qx(iptables -D $rule $_);
    }
}