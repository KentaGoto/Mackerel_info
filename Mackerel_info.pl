use strict;
use warnings;
use WebService::Mackerel;
use JSON;
use Data::Dumper;
use Term::ANSIColor qw( :constants );
use Win32::Console::ANSI;

#$Term::ANSIColor::AUTORESET = 1;

# instance
my $mkr = WebService::Mackerel->new(
    api_key      => '<API_KEY>',
    service_name => '<SERVICE_NAME>',
);

# Get a list of host names
my $response = decode_json( $mkr->get_hosts );
my $hosts    = $response->{hosts};

#print Dumper $hosts;
#exit;

# Host name output
for my $host ( @{$hosts} ) {

    # Hostname
    my $host_name = $host->{name};
    print 'HostName: ' . BOLD GREEN, $host_name . "\n" . RESET;

    # IPv4
    print 'IPv4: ';
    my $ip = $host->{interfaces}[0]->{ipAddress};
    if ( defined $ip ) {
        print $ip . "\n";
    }
    elsif ( not defined $ip and defined $host_name ) { # If you can't get an IP address on Mackerel, hit the command to get the IP address.
		my @ipconfig = `ping $host_name`;
		for my $l (@ipconfig){
			# If it matches the IP,
			if ($l =~ /((?:[0-9]{1,3})\.(?:[0-9]{1,3})\.(?:[0-9]{1,3})\.(?:[0-9]{1,3}))/){
				$ip = $1;
				next;
			}
		}
		print $ip . "\n";
    } else {
        print RED, "Could not get\n" . RESET;
	}

    # OS
    my $os               = $host->{meta}->{kernel}->{os};
    my $platform_name    = $host->{meta}->{kernel}->{platform_name};
    my $platform_version = $host->{meta}->{kernel}->{platform_version};
    print 'OS: ' . $os;
    if ( defined $platform_name and defined $platform_version ) {
        print ', ' . $platform_name . ' ' . $platform_version . "\n";
    }
    else {
        print "\n";
    }

    # Memory
    my $free_memory  = $host->{meta}->{memory}->{free};
    my $total_memory = $host->{meta}->{memory}->{total};
    $free_memory  =~ s{kb}{}i;
    $total_memory =~ s{kb}{}i;
    $free_memory  = $free_memory / 1024;  # KB to MB
    $total_memory = $total_memory / 1024; # KB to MB
    print 'Free memory: ' . $free_memory . 'MB' . "\n";   # memory free space
    print 'Total memory: ' . $total_memory . 'MB' . "\n"; # memory free space
    print "\n";
}

print "Done!\n\n";
print 'Press any key to exit.' . "\n";

system 'pause > nul';
