use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use AnyEvent::Twitter::Stream::OAuth;
use YAML;

my $oauth = AnyEvent::Twitter::Stream::OAuth->new(
    type                => 'stream',
    consumer_key        => 'CONSUMER_KEY',
    consumer_secret     => 'CONSUMER_SECRET',
    access_token        => 'ACCESS_TOKEN',
    access_token_secret => 'ACCESS_TOKEN_SECRET',
);

my %req = $oauth->make_request(method => 'filter', track => '#nowplaying');
warn YAML::Dump(\%req);
