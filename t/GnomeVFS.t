#!/usr/bin/perl -w
use strict;
use Gnome2::VFS;

use Test::More tests => 1;

# $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/t/GnomeVFS.t,v 1.2 2003/11/07 19:55:58 kaffeetisch Exp $

###############################################################################

Gnome2::VFS -> init();

ok(Gnome2::VFS -> initialized());

###############################################################################

# FIXME: how to reliably test this? seems to require a running nautilus.
# my ($result, $uri) = Gnome2::VFS -> find_directory("/home", "desktop", 0, 1, 0755);
# is($result, "ok");
# isa_ok($uri, "Gnome2::VFS::URI");

###############################################################################

Gnome2::VFS -> shutdown();
