use strict;

use FindBin;
use lib "$FindBin::Bin/";
use lib "$FindBin::Bin/../lib";

use AETwitterStreamSample;
use Encode qw/encode_utf8/;

my $oauth = AETwitterStreamSample->new(
    type => 'stream',   # (type is here).twitte.com
    consumer_key        => 'CONSUMER_KEY',
    consumer_secret     => 'CONSUMER_SECRET',
    access_token        => 'ACCESS_TOKEN',
    access_token_secret => 'ACCESS_TOKEN_SECRET',
    track => 'worldcup', # if type is stream and method eq 'filter'
    on_tweet => sub {
        my $tweet = shift;
        if (my $text = $tweet->{text}) {
            print encode_utf8 "$tweet->{user}{screen_name}: $text\n";
        }
    }
);

AE::cv->recv;
