#!/usr/bin/perl -w
use strict;
use Gnome2::VFS;

use Cwd qw(cwd);

use Test::More tests => 3;

# $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/t/GnomeVFSFileInfo.t,v 1.3 2003/11/23 21:48:37 kaffeetisch Exp $

###############################################################################

Gnome2::VFS -> init();

###############################################################################

my $info = Gnome2::VFS -> get_file_info(cwd() . "/" . $0, qw(get-mime-type));

isa_ok($info, "Gnome2::VFS::FileInfo");
ok($info -> matches($info));
is($info -> get_mime_type(), $info -> { mime_type });

###############################################################################

Gnome2::VFS -> shutdown();
