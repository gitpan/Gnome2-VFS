#!/usr/bin/perl -w
use strict;
use Gnome2::VFS -init;

use Cwd qw(cwd);

use Test::More tests => 3;

# $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/t/GnomeVFSFileInfo.t,v 1.4 2003/12/12 23:08:13 kaffeetisch Exp $

###############################################################################

my $info = Gnome2::VFS -> get_file_info(cwd() . "/" . $0, qw(get-mime-type));

isa_ok($info, "Gnome2::VFS::FileInfo");
ok($info -> matches($info));
is($info -> get_mime_type(), $info -> { mime_type });

###############################################################################

Gnome2::VFS -> shutdown();
