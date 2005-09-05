#!/usr/bin/perl -w
use strict;
use Gnome2::VFS;

use Cwd qw(cwd);

use Test::More;

# $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/t/GnomeVFSFileInfo.t,v 1.10 2005/06/22 17:36:06 kaffeetisch Exp $

plan -d "$ENV{ HOME }/.gnome" ?
  (tests => 12) :
  (skip_all => "You have no ~/.gnome");

Gnome2::VFS -> init();

###############################################################################

my $info = Gnome2::VFS -> get_file_info(cwd() . "/" . $0, qw(get-mime-type));

isa_ok($info, "Gnome2::VFS::FileInfo");
ok($info -> matches($info));
is($info -> get_mime_type(), $info -> { mime_type });

###############################################################################

$info = Gnome2::VFS::FileInfo -> new({
  name => $0,
  type => "regular",
  permissions => [qw(user-read user-write)],
  flags => "local",
  size => 23,
  mime_type => "text/plain"
});

isa_ok($info, "Gnome2::VFS::FileInfo");
ok($info -> matches($info));
is($info -> get_mime_type(), $info -> { mime_type });

is($info -> { name }, $0);
is($info -> { type }, "regular");
is($info -> { permissions }, [qw(user-read user-write)]);
is($info -> { flags }, "local");
is($info -> { size }, 23);
is($info -> { mime_type }, "text/plain");

###############################################################################

Gnome2::VFS -> shutdown();
