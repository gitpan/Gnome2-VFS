#!/usr/bin/perl -w
use strict;
use Gnome2::VFS;

use Test::More;

# $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/t/GnomeVFSResolve.t,v 1.2 2005/03/07 21:16:45 kaffeetisch Exp $

unless (-d "$ENV{ HOME }/.gnome") {
  plan(skip_all => "You have no ~/.gnome");
}

unless (Gnome2::VFS -> CHECK_VERSION(2, 8, 0)) {
  plan(skip_all => "This is new in 2.8");
}

plan(tests => 2);

Gnome2::VFS -> init();

###############################################################################

my $handle = Gnome2::VFS -> resolve("localhost");
isa_ok($handle, "Gnome2::VFS::Resolve::Handle");
isa_ok($handle -> next_address(), "Gnome2::VFS::Address");

$handle -> reset_to_beginning();

###############################################################################

Gnome2::VFS -> shutdown();
