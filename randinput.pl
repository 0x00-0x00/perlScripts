#!/usr/bin/env perl
srand time;
my $size = 256;
my @char = ('A'..'Z', 'a'..'z', 0..9, qw(! @ # $ % ^ & * - + = ));
my $junk = join ("", @char[ map{ rand @char } (1..$size) ]);
print "$junk";

