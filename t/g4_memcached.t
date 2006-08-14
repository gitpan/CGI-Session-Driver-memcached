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
    if ( $@ ) {
        plan(skip_all=>"$_ is NOT available");
        exit 0;
    }
}

my $memcached = Cache::Memcached->new({
    servers => \@servers,
    debug   => 1,
});

require CGI::Session::Driver::memcached;
my $t = CGI::Session::Test::Default->new(
    dsn => "dr:memcached",
    args=> { Memcached => $memcached }
);

plan tests => $t->number_of_tests;
$t->run();
