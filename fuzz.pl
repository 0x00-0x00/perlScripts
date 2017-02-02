#!/usr/bin/env perl

#use strict;
#use warnings;
use IO::Socket;

sub generateJunk {
    my $n = scalar(@_);
    if($n < 2) {
        return 0;
    }
    my $size = $_[0];
    my $seed = $_[1];
    srand unpack("L", $seed);
    my @char = ('A'..'Z', 'a'..'z', 0..9, qw(! @ # $ % ^ & * + - = ));
    my $junk = join("", @char[map{ rand @char } (1..$size) ]);
    return $junk;
}


# Script to send junk input to a listening socket
my $act = 0;
print "[-] Type the target IP address: ";
my $server = <STDIN>;
chomp $server;

print "[-] Type the target port: ";
my $port = <STDIN>;
chomp $port;

print "[-] Type how many iterations of fuzzing do you wish to do: ";
my $input = <STDIN>;
chomp $input;

print "[-] Type how many time of interval between requests: ";
my $interval = <STDIN>;
chomp $interval;

print "\n[*] Fuzzing session with $input cycles set to destination $server:$port\n";

my $seed;
my $randSeed;
open(RAND, "/dev/urandom");
read(RAND, $seed, 4);
srand(unpack("L", $seed));

for(my $i = 0; $i < int($input); $i++) {
    
    my $socks = IO::Socket::INET->new(
        Proto=> "tcp",
        PeerAddr=> $server,
        PeerPort=> $port,
        TimeOut=>5,
        #Reuse=>1
    );
    
    if(not $socks) {
        print "Can't create no more sockets.\n";
        exit;
    }

    my $bufflen = rand(4096);
    my $blob_size = $bufflen;
    read(RAND, $randSeed, 4);
    my $buffer = generateJunk($bufflen, $randSeed);

    if($i % 2 == 0 ) {
        read(RAND, $buffer, $bufflen);
    }
    my $packTemplate = sprintf "ssa%d", $bufflen;
    my $junk = pack $packTemplate, $act, $blob_size, $buffer;
    printf "Sending junk data to $server:$port (%d bytes)\n", length $junk;
    $socks->send($buffer) if $socks;
    #Close sockets
    shutdown($socks, 2) if $socks;
    close($socks) if $socks;
    sleep $interval;
}

print "[*] Fuzzing complete.";


 

