#!/usr/bin/perl

#@iptables = qx(iptables -L -vn);

open(my $fh_iptables, "<", fileProva) or die $!;

%chain_drop;

while(<$fh_iptables>){
    chomp;
    if($_ =~ /^Chain\s+(\S+)\s+\(policy DROP (\d+)\s.*/){
        $chain_drop{$1} = $2;
    } elsif ($_ =~ /^Chain\s+(\S+?)[\s\(].*/ && ($1 ne "OUTPUT" && $1 ne "INPUT" && $1 ne "FORWARD")){
        $customChain = $1; 
        $chain_drop{$customChain} = 0;
    }

    if($customChain && $_ =~ /\s+(\d+)\s\S\s(\S+).*/){
        $acceptedInternetRed = 0;
        if($2 eq "DROP"){
            $chain_drop{$customChain} += $1; 
        } elsif ($1 eq "internetRED" && $2 eq "ACCEPT"){
            $acceptedInternetRed += $1;
        }
    }
}
close($fh_iptables or die $!);

if($acceptedInternetRed > 10) {
    #qx(iptables -F internetRED);
}

$totalDropped = 0;

foreach $key (keys %chain_drop){
    print "$key: $chain_drop{$key}\n";
    $totalDropped += $chain_drop{$key};
}

print "---\nTOTALE: $totalDropped\n";