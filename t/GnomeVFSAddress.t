#!/usr/bin/perl -w
use strict;
use Gnome2::VFS;

use Test::More;

# $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/t/GnomeVFSAddress.t,v 1.4 2005/12/14 02:46:13 rwmcfa1 Exp $

unless (-d "$ENV{ HOME }/.gnome") {
  plan(skip_all => "You have no ~/.gnome");
}

unless (Gnome2::VFS -> CHECK_VERSION(2, 8, 0)) {
  plan(skip_all => "This is new in 2.8");
}

plan(tests => 5);

Gnome2::VFS -> init();

###############################################################################

my $address = Gnome2::VFS::Address -> new_from_string("127.0.0.1");
isa_ok($address, "Gnome2::VFS::Address");
like($address -> get_family_type(), qr/^\d+$/);
is($address -> to_string(), "127.0.0.1");

SKIP: {
  skip "forget_cache is new in 2.12", 2
    unless Gnome2::VFS -> CHECK_VERSION(2, 13, 1);
  ok($address -> equal($address));
  ok($address -> match($address, 4));
}

###############################################################################

Gnome2::VFS -> shutdown();
