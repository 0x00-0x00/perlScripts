#!/usr/bin/env perl


use Scalar::Util;
use IO::Socket;

sub generateJunk {
    srand time;
    $n = scalar(@_);
    if($n < 1) {
        return 0;
    }
    my $size = @_[0];
    my @char = ('A'..'Z', 'a'..'z', 0..9, qw(! @ # $ % ^ & * + - = ));
    my $junk = join("", @char[map{ rand @char } (1..$size) ]);
    printf "[+] Generated %d bytes of junk.\n", length $junk;
    return $junk;
}


# Script to send junk input to a listening socket
my $act = 0;
my $server = '127.0.0.1';
my $port = 8888;

print "Type how many iterations of fuzzing do you wish to do: ";
my $input = <STDIN>;
my $valid_input = 0;
chomp $input;


for(my $i = 0; $i < $input; $i++) {
    printf "Iteration #%d\n", $i;
    if($socks = IO::Socket::INET->new(
            Proto=>"tcp",
            PeerAddr=>$server,
            PeerPort=>$port,
            TimeOut=>5,
        )) {
        my $bufflen = rand(4096);
        my $blob_size = $bufflen;
        my $buffer = generateJunk($bufflen);
        my $junk = pack "ssa128", $act, $blob_size, $buffer;
        printf "Sending buffer to port $port (%d bytes)\n", length $junk;
        $socks->send($buffer);
        sleep 1;
    }
}


