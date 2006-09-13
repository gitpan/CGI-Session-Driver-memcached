#!/usr/bin/perl

use strict;
use diagnostics;

my @servers = ('localhost:11211');
if ($ENV{CGISESS_MEMCACHED_SERVERS}) {
    @servers = split ':', $ENV{CGISESS_MEMCACHED_SERVERS};
}

use Test::More;
use CGI::Session::Test::Default;

for (qw(Cache::Memcached)) {
    eval "require $_";
    if ($@) {
        plan(skip_all=>"$_ is NOT available");
        exit 0;
    }
}

my $memcached = Cache::Memcached->new({
    servers => \@servers,
    debug   => 1,
});

my $TEST_KEY = '__cgi_session_driver_memcached';
$memcached->set($TEST_KEY, 1);
unless (defined $memcached->get($TEST_KEY)) {
    plan(skip_all=>"memcached server is NOT available");
    exit 0;
}

require CGI::Session::Driver::memcached;
my $t = CGI::Session::Test::Default->new(
    dsn => "dr:memcached",
    args=> { Memcached => $memcached }
);

plan tests => $t->number_of_tests;
$t->run();
