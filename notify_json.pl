#!/usr/bin/perl
 
use strict;
use warnings;
 
use JSON;
use IPC::Run qw(run); 
use Data::Dumper;

my $community_host_to_blackhole = '65000:777';

# You can provide multiple next hops here
my @next_hops = ("1.2.3.4", "2.3.4.5");

# Write some debug to /tmp
 
open my $fl, ">>", "/tmp/fastnetmon_ecmp_announces.log" or die "Could not open file for writing";
 
# This script executed from FastNetMon this way: ban 11.22.33.44
 
if (scalar @ARGV != 2) {
    print {$fl} "Please specify all arguments. Got only: @ARGV\n";
    die "Please specify all arguments\n";
}
 
my ($action, $ip_address) = @ARGV;
# action could be: ban, unban, partial_block
 
# Read data from stdin
my $input_attack_details = join '', <STDIN>;
 
# try to decode this data to json
my $attack_details = eval{  decode_json($input_attack_details); };
 
# report error
 
if ($@) {
    print {$fl} "JSON decode failed: $input_attack_details\n";
 
    die "JSON decode failed\n";
}
 
print {$fl} "Received notification about $ip_address with action $action\n";
 
print {$fl} Dumper($attack_details);

my $host_group = $attack_details->{attack_details}->{'host_group'};

my $command = '';

if ($action eq 'ban') {
    # Make unique announce for each next hop
    for (my $i = 0; $i <= $#next_hops; $i++) { 
        # We need to use unique identifier for each announce
        $command = "gobgp global rib add -a ipv4 $attack_details->{ip}/32 community $community_host_to_blackhole nexthop $next_hops[$i] identifier $i";
    }
} elsif ($action eq 'unban') {
    # To withdraw them all need to provide identifier each time
    for (my $i = 0; $i <= $#next_hops; $i++) {
        $command = "gobgp global rib del -a ipv4 $attack_details->{ip}/32 identifier $i";
    }
} else {
    die "Unknown action $action";
}

print {$fl} "Will execute command $command for group $host_group\n";
my $res = system($command);

if ($res != 0) {
    print {$fl} "Command failed with code $res\n";
} else {
    print {$fl} "Command executed correctly\n";
}

close $fl;
 
exit 0;
