#!/usr/bin/perl

@arp = qx(arp -n) or die$!;
shift @arp;

foreach(@arp){

}