#!/usr/bin/perl

use common::sense;

use AnyEvent::HTTP 'http_request';
use Encode qw/encode_utf8/;

use lib 'AnyEvent-Twitter-Stream-OAuth/lib';
use AnyEvent::Twitter::Stream::OAuth;

my $oauth = AnyEvent::Twitter::Stream::OAuth->new(
    type => 'chirpstream',
    consumer_key        => 'CONSUMER_KEY',
    consumer_secret     => 'CONSUMER_SECRET',
    access_token        => 'ACCESS_TOKEN',
    access_token_secret => 'ACCESS_TOKEN_SECRET',
);

my ($method, $url, $args) = $oauth->make_request;

http_request(
    $method, $url, %$args,
    sub {
        my $hdl = shift;
        my $r = sub {
            my (undef, $json) = @_;
            if (my $text = $json->{text}) {
                print encode_utf8 "$json->{user}{screen_name}: $text\n";
            }
        };
        $hdl->on_read(sub { $hdl->push_read( json => $r ); });
    }
);

AE::cv->recv;
