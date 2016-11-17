#!/usr/bin/perl -w

use strict;
use warnings;
use Getopt::Long;
use URI::Escape;
use Data::Dumper;

# Set default options
# Path to Nagios availability CGI
my $cgi = '/usr/lib64/nagios/cgi-bin/avail.cgi';

# User with permission to access the CGI
my $user = 'nagios';

# Default timeperiod
my $timeperiod = 'lastmonth';

# Default output format
my $outputformat = 'dump';
my $verbose = 0;

# Variables with no default
my ($host, $service);

# Read in command-line options
GetOptions (
	'cgi=s'          => \$cgi,
	'u|user=s'       => \$user,
	'h|host=s'       => \$host,
	's|service=s'    => \$service,
	't|timeperiod=s' => \$timeperiod,
	'o|output=s'     => \$outputformat,
	'v|verbose'      => \$verbose,
);

# Make sure mandatory vars are set
if (!$host) {
	print "Must set -h|--host\n";
	exit;
}

if (!$service) {
	print "Must set -s|--service\n";
	exit;
}

# Set env vars based on our options
$ENV{'REQUEST_METHOD'} = 'GET';
$ENV{'REMOTE_USER'} = $user;
$ENV{'QUERY_STRING'} = "host=${host}&service=${service}&timeperiod=${timeperiod}&noheader=yes&initialassumedservicestate=6";

# Execute the CGI, passing in the environment variables
my $output = `$cgi`;

# Grab just the table content from the output
$output =~ m/<TABLE BORDER=0 CLASS='data'>(.*)<\/table>/gis;
my @table = split(/\n/, $1);

# Go through table and find lines with rowspan
# <td CLASS='serviceOK' rowspan=3>OK</td>
my $i = 0;
foreach my $row (@table) {
	if ($row =~ m/<td CLASS='(\w+)' rowspan=(\d+)>(\w+)<\/td>/) {
		# Fix this row by taking out the rowspan
		$table[$i] =~ s/<td CLASS='(\w+)' rowspan=(\d+)>(\w+)<\/td>/<td CLASS='$1'>$3<\/td>/;
		# Fix the next n rows by adding in a <td>
		my $n = $2-1;
		my $class = $1;
		my $var = $3;
		for my $x ($i+1 .. $i+$n) {
			$table[$x] =~ s/<tr CLASS='(\w+)'>/<tr CLASS='$1'><td CLASS='$class'>$var<\/td>/;
		}
	}
	$i++;
}

# Now iterate over the array again and shove it all into a hash
my %hash;
foreach my $row (@table) {
	#                                         State                      Type                       # Time                    # Percent
	if ($row =~ m/^<tr CLASS='\w+'><td CLASS='\w+'>(\w+)<\/td><td CLASS='\w+'>(\w+)<\/td><td CLASS='\w+'>([\d\w\ ]+)<\/td><td CLASS='\w+'>(\d+\.\d+%)<\/td>.*/) {
		$hash{$1}{$2}{'Time'} = $3;
		$hash{$1}{$2}{'Percent'} = $4;
	}
}

if ($outputformat eq 'dump') {
	print Dumper(%hash);
} elsif ($outputformat eq 'uptime') {
	if ($verbose) {
		print "Total uptime percentage for service $service on host $host during period $timeperiod is $hash{'OK'}{'Total'}{'Percent'}\n";
	} else {
		print "$hash{'OK'}{'Total'}{'Percent'}\n";
	}
} elsif ($outputformat eq 'downtime') {
        if ($verbose) {
		print "Total down duration for service $service on host $host during period $timeperiod is $hash{'CRITICAL'}{'Total'}{'Time'}\n";
	} else {
		print "$hash{'CRITICAL'}{'Total'}{'Time'}\n";
	}
} else {
	print "Must supply valid -o|--output\n";
}
