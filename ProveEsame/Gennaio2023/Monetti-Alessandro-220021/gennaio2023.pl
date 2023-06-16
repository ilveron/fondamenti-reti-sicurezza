#!/usr/bin/perl

die "Numero di argomenti non valido" if(scalar @ARGV != 1);

my $file = shift @ARGV;
chomp $file;

my @arp = qx(arp -n);
shift @arp;

my @netstat = qx(netstat -n);
shift @netstat;
shift @netstat;

my %connessioni;

open(my $fh_in, "<", "$file") or die $!;
while(<$fh_in>){
    chomp;
    $mac = $_;
    my $ris = trovaEntry($mac);
    if($ris){
        foreach (@netstat){
            chomp;
            $_ =~ /\S+\s+\S+\s+\S+\s+(\S+):\S+\s+(\S+):\S+\s+(\S+)/;
            print "$1 - $2 - $3\n";
            if($2 eq $ris && $3 eq "ESTABLISHED"){
                if(exists $connessioni{$2}){
                    ++$connessioni{$2};
                }
                else {
                    $connessioni{$2} = 1; 
                }
            }
            
            last if($_ =~ /unix/);
        }
    } 
}
close($fh_in) or die $!;

for my $conn (keys %connessioni){
    qx(iptables -A INPUT -p tcp -s $connessioni{$conn} -j DROP) if($connessioni{$conn} > 5);
} 

sub trovaEntry($mac) {
    foreach (@arp){
        my $entry = $_;
        chomp $entry;
        #$entry =~ /(.*)?\s+?[A-Za-z]+?\s+?([a-f0-9:]+).*/;
        $entry =~ /(\S+)\s+\S+\s+(\S+).*/;
        if($mac eq $2){
            return $1;
        }
    }
    return 0;
}