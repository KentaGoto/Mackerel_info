use strict;
use warnings;
use WebService::Mackerel;
use JSON;
use Data::Dumper;
use Term::ANSIColor qw( :constants );
use Win32::Console::ANSI;

#$Term::ANSIColor::AUTORESET = 1;

# WebService::Mackerelのインスタンス
my $mkr = WebService::Mackerel->new(
    api_key      => '<API_KEY>',
    service_name => '<SERVICE_NAME>',
);

# ホスト名一覧取得
my $response = decode_json( $mkr->get_hosts );
my $hosts    = $response->{hosts};

#print Dumper $hosts;
#exit;

# ホスト名出力
for my $host ( @{$hosts} ) {

    # ホスト名
    my $host_name = $host->{name};
    print 'HostName: ' . BOLD GREEN, $host_name . "\n" . RESET;

    # IPv4
    print 'IPv4: ';
    my $ip = $host->{interfaces}[0]->{ipAddress};
    if ( defined $ip ) {
        print $ip . "\n";
    }
    elsif ( not defined $ip and defined $host_name ) { # MackerelでIPアドレスが取れない場合は、コマンド叩いてIPアドレスをゲットする
		my @ipconfig = `ping $host_name`;
		for my $l (@ipconfig){
			# IPにマッチしたら抜ける
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

    # メモリ
    my $free_memory  = $host->{meta}->{memory}->{free};
    my $total_memory = $host->{meta}->{memory}->{total};
    $free_memory  =~ s{kb}{}i;
    $total_memory =~ s{kb}{}i;
    $free_memory  = $free_memory / 1024; # KB to MB
    $total_memory = $total_memory / 1024; # KB to MB
    print 'Free memory: ' . $free_memory . 'MB' . "\n";  # メモリ空き容量
    print 'Total memory: ' . $total_memory . 'MB' . "\n"; # メモリ空き容量
    print "\n";
}

print "Done!\n\n";
print 'Press any key to exit.' . "\n";

system 'pause > nul';
