#!/usr/bin/perl -w
use strict;
use Gnome2::VFS;

use Test::More;

# $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/t/GnomeVFS.t,v 1.6 2004/07/29 17:36:02 kaffeetisch Exp $

plan -d "$ENV{ HOME }/.gnome" ?
  (tests => 2) :
  (skip_all => "You have no ~/.gnome");

###############################################################################

Gnome2::VFS -> init();
ok(Gnome2::VFS -> initialized());

###############################################################################

# FIXME: how to reliably test this? seems to require a running nautilus.
# my ($result, $uri) = Gnome2::VFS -> find_directory("/home", "desktop", 0, 1, 0755);
# is($result, "ok");
# isa_ok($uri, "Gnome2::VFS::URI");

ok(defined Gnome2::VFS -> result_to_string("ok"));

###############################################################################

Gnome2::VFS -> shutdown();
