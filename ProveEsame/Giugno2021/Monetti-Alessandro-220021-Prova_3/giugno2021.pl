#!/usr/bin/perl

# ATTENZIONE: NON GESTISCE CASO IN CUI CI SIA UNA RIGA CON TARGET ACCEPT DOPO UNA RIGA CON DROP
my @iptables = qx(iptables -L -vn) or die $!;

my %chain_drop;
my $found = 0;
my $accept_sum = 0;
foreach(@iptables){
    chomp;
    if($found == 0 && $_ =~ /Chain\s(\S+)\s\(policy\sDROP\s(\d+).*/){
        $chain = $1;
        $drop = $2;
        %chain_drop{$chain} = $drop;
    }
    elsif($found == 0 && $_ =~ /Chain\sinternetRED.*/){
        $found = 1;
        shift @iptables;
    }
    elsif($found == 1){
        $accept_sum += $1 if($_ =~ /\s+(\d+).*?ACCEPT.*/);
    }
    else{
        $found = 0;
    }
}

my $drop_sum = 0;

foreach $chain (keys %chain_drop){
    print "$chain:\t$chain_drop{$chain}\n";
    $drop_sum += $chain_drop{$chain};
}
print "-------------------\n";
print "TOTALE:\t$drop_sum\n";

qx(iptables -F internetDMZ) or die $!;