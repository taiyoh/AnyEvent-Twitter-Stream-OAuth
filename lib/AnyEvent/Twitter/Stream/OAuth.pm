package AnyEvent::Twitter::Stream::OAuth;

use strict;
use warnings;
our $VERSION = '0.01';

use Net::OAuth;
use URI::Escape;
use MIME::Base64;

our $DOMAIN = '.twitter.com';

our %TYPES = (
    chirpstream => {
        path   => '/2b/user.json',
        params => {}
    },
    stream => {
        path   => '/1/statuses/%s.json',
        params => {
            firehose => [],
            links    => [],
            retweet  => [],
            sample   => [],
            filter   => [ qw(track follow locations) ],
        }
    }
);

sub GET_ACCESS_TOKEN {
    use Net::Twitter::Lite;
    # from http://search.cpan.org/~mmims/Net-Twitter-Lite-0.10003/lib/Net/Twitter/Lite.pm#OAUTH_EXAMPLES

    my $nt = Net::Twitter::Lite->new(@_);

    # The client is not yet authorized: Do it now
    print "Authorize this app at ", $nt->get_authorization_url, " and enter the PIN#\n";

    my $pin = <STDIN>; # wait for input
    chomp $pin;

    my ($access_token, $access_token_secret) = $nt->request_access_token(verifier => $pin);

    # Everything's ready
    return {
        access_token        => $access_token,
        access_token_secret => $access_token_secret
    };
}

sub new {
    my $package = shift;
    my %args = (@_ > 1) ? @_ : %{ $_[0] };

    die "requires type"                unless $args{type};
    die "requires consumer_key"        unless $args{consumer_key};
    die "requires consumer_secret"     unless $args{consumer_secret};
    die "requires access_token"        unless $args{access_token};
    die "requires access_token_secret" unless $args{access_token_secret};

    return bless \%args, $package;
}

sub make_request {
    my $self = shift;

    my %args = @_ ? @_ : ();

    my $url = 'http://'.$self->{type}.$DOMAIN;
    $url .= $TYPES{$self->{type}}{path};

    $args{request_method} ||= 'GET';
    $args{extra_params}   ||= {};

    my $method = delete $args{method} || 'filter';
    $url = sprintf($url, $method);

    my ($username, $password);
    my %post_params = ();
    if ($self->{type} eq 'stream') {
        if ($method eq 'filter') {
            #$args{request_method} = 'POST';
        }
    }

    my %post_args = ();
    if ($TYPES{$self->{type}}{params}{$method}) {
        for my $p (@{ $TYPES{$self->{type}}{params}{$method} }) {
            $post_args{$p} = delete $args{$p} if exists $args{$p};
        }
    }

    if ($args{request_method} eq 'GET') {
        $args{extra_params} = {
            %{ $args{extra_params} || {} },
            %post_args
        };
    }

    my $request = Net::OAuth->request('protected resource')->new(
        signature_method => 'HMAC-SHA1',
        version          => '1.0',
        %args,
        request_url      => $url,
        consumer_key     => $self->{consumer_key},
        consumer_secret  => $self->{consumer_secret},
        token            => $self->{access_token},
        token_secret     => $self->{access_token_secret},
        timestamp => time,
        nonce     => time ^ $$ ^ int(rand 2**32),
    );

    $request->sign;

    if ($args{request_method} eq 'GET') {
        return (
            GET => $request->to_url,
            {
                want_body_handle => 1
            }
        );
    }
    elsif ($args{request_method} eq 'POST') {
        my $request_body = join '&', map "$_=" . URI::Escape::uri_escape($post_args{$_}), keys %post_args;
        my $headers = {
            Accept         => '*/*',
            Authorization  => $request->to_authorization_header,
            'Content-Type' => 'application/x-www-form-urlencoded'
        };

        (my $auth_param = $request->to_url) =~ s{${url}\?}{};
        $request_body .= '&'. $auth_param;
        return (
            POST => $url,
            {
                headers => $headers,
                body    => $request_body,
                want_body_handle => 1
            }
        );
    }

    return;
}


1;
__END__

=head1 NAME

AnyEvent::Twitter::Stream::OAuth -

=head1 SYNOPSIS

  use AnyEvent::Twitter::Stream::OAuth;

=head1 DESCRIPTION

AnyEvent::Twitter::Stream::OAuth is

=head1 AUTHOR

Taiyoh Tanaka E<lt>sun.basix@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
