#!/usr/bin/perl -w
use strict;
use Gnome2::VFS;

use Test::More tests => 29;

# $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/t/GnomeVFSURI.t,v 1.3 2003/11/07 19:55:58 kaffeetisch Exp $

###############################################################################

Gnome2::VFS -> init();

###############################################################################

my $uri = Gnome2::VFS::URI -> new("http://www.freenet.de");

isa_ok($uri, "Gnome2::VFS::URI");

ok($uri -> equal(Gnome2::VFS::URI -> new("http://www.freenet.de")));
ok($uri -> is_parent(Gnome2::VFS::URI -> new("http://www.freenet.de/tmp/argh.html"), 1));
ok(not $uri -> has_parent());

is($uri -> to_string(qw(toplevel_method)), "www.freenet.de");
is($uri -> append_string("ble.html") -> to_string(), "http://www.freenet.de/ble.html");
is($uri -> append_path("bli.html") -> to_string(), "http://www.freenet.de/bli.html");
is($uri -> append_file_name("blo.html") -> to_string(), "http://www.freenet.de/blo.html");
ok(not $uri -> is_local());

SKIP: {
  skip("resolve_relative, it changed in 2.3.1", 1)
    unless (join("", Gnome2::VFS -> get_version_info()) >= 231);

  is($uri -> resolve_relative("bla.html") -> to_string(), "http://www.freenet.de/bla.html");
}

###############################################################################

$uri = Gnome2::VFS::URI -> new("http://www.freenet.de/tmp/argh.html");

ok($uri -> has_parent());
is($uri -> get_parent() -> to_string(), "http://www.freenet.de/tmp");

###############################################################################

$uri = Gnome2::VFS::URI -> new('ftp://bla:bla@ftp.freenet.de:21/pub');

is($uri -> get_host_name(), "ftp.freenet.de");
is($uri -> get_scheme(), "ftp");
is($uri -> get_host_port(), 21);
is($uri -> get_user_name(), "bla");
is($uri -> get_password(), "bla");

###############################################################################

$uri = Gnome2::VFS::URI -> new("ftp://ftp.gna.org");

$uri -> set_host_name("ftp.gnu.org");
$uri -> set_host_port(21);
$uri -> set_user_name("blub");
$uri -> set_password("blub");
is($uri -> get_host_name(), "ftp.gnu.org");
is($uri -> get_scheme(), "ftp");
is($uri -> get_host_port(), 21);
is($uri -> get_user_name(), "blub");
is($uri -> get_password(), "blub");

###############################################################################

$uri = Gnome2::VFS::URI -> new("/usr/bin/perl");

is($uri -> get_path(), "/usr/bin/perl");
# FIXME: $uri -> get_fragment_identifier();

is($uri -> extract_dirname(), "/usr/bin");
is($uri -> extract_short_name(), "perl");
is($uri -> extract_short_path_name(), "perl");

###############################################################################

foreach (Gnome2::VFS::URI -> list_parse("file:///usr/bin/python\nfile:///usr/bin/curl")) {
  isa_ok($_, "Gnome2::VFS::URI");
}

###############################################################################

is(Gnome2::VFS::URI -> make_full_from_relative("/usr/bin/", "perl"), "/usr/bin/perl");

###############################################################################

Gnome2::VFS -> shutdown();
