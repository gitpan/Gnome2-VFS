#!/usr/bin/perl -w
use strict;
use Gnome2::VFS;

use Cwd qw(cwd);

use Test::More;

# $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/t/GnomeVFSFileInfo.t,v 1.4.2.1 2004/03/27 16:17:56 kaffeetisch Exp $

plan -d "$ENV{ HOME }/.gnome" ?
  (tests => 3) :
  (skip_all => "You have no ~/.gnome");

Gnome2::VFS -> init();

###############################################################################

my $info = Gnome2::VFS -> get_file_info(cwd() . "/" . $0, qw(get-mime-type));

isa_ok($info, "Gnome2::VFS::FileInfo");
ok($info -> matches($info));
is($info -> get_mime_type(), $info -> { mime_type });

###############################################################################

Gnome2::VFS -> shutdown();
