#!/usr/bin/perl -w
use strict;
use Gnome2::VFS;

use Cwd qw(cwd);

use Test::More tests => 24;

# $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/t/GnomeVFSUtils.t,v 1.4 2003/11/23 21:48:37 kaffeetisch Exp $

###############################################################################

Gnome2::VFS -> init();

###############################################################################

# Gnome2::VFS -> escape_set(...);
# Gnome2::VFS -> icon_path_from_filename(...);
# Gnome2::VFS -> url_show(...);

is(Gnome2::VFS -> format_file_size_for_display(1200000000), "1.1 GB");

SKIP: {
  skip("escape_string, format_uri_for_display, gnome_vfs_make_uri_from_input, make_uri_canonical_strip_fragment, uris_match, get_uri_scheme and make_uri_from_shell_arg are new in 2.1.3", 7)
    unless (Gnome2::VFS -> check_version(2, 1, 3));

  is(Gnome2::VFS -> escape_string('%$§'), '%25%24%A7');
  is(Gnome2::VFS -> format_uri_for_display("/usr/bin/perl"), "/usr/bin/perl");
  is(Gnome2::VFS -> make_uri_from_input("gtk2-perl.sf.net"), "http://gtk2-perl.sf.net");
  is(Gnome2::VFS -> make_uri_canonical_strip_fragment("http://gtk2-perl.sf.net#bla"), "http://gtk2-perl.sf.net");
  ok(Gnome2::VFS -> uris_match("http://gtk2-perl.sf.net", "http://gtk2-perl.sf.net"));
  is(Gnome2::VFS -> get_uri_scheme("http://gtk2-perl.sf.net"), "http");
  is(Gnome2::VFS -> make_uri_from_shell_arg("/~/bla"), "file:///~/bla");
}

SKIP: {
  skip("make_uri_from_input_with_dirs is new in 2.2.5", 1)
    unless (Gnome2::VFS -> check_version(2, 2, 5));

  is(Gnome2::VFS -> make_uri_from_input_with_dirs("~/tmp", qw(homedir)), "file://$ENV{ HOME }/tmp");
}

foreach (Gnome2::VFS -> escape_path_string('%$§'),
         Gnome2::VFS -> escape_host_and_path_string('%$§')) {
  is($_, '%25%24%A7');
  is(Gnome2::VFS -> unescape_string($_), '%$§');
}

is(Gnome2::VFS -> escape_slashes("/%/"), "%2F%25%2F");

SKIP: {
  skip ("make_uri_canonical is borken in versions prior to 2.1.0", 1)
    unless (Gnome2::VFS -> check_version (2, 1, 0));

  is(Gnome2::VFS -> make_uri_canonical("bla/bla.txt"), "file:///bla/bla.txt");
}

is(Gnome2::VFS -> make_path_name_canonical("/bla"), "/bla");
is(Gnome2::VFS -> expand_initial_tilde("~/bla"), "$ENV{ HOME }/bla");
is(Gnome2::VFS -> unescape_string_for_display("%2F%25%2F"), "/%/");
is(Gnome2::VFS -> get_local_path_from_uri("file:///bla"), "/bla");
is(Gnome2::VFS -> get_uri_from_local_path("/bla"), "file:///bla");
ok(Gnome2::VFS -> is_executable_command_string("perl -wle 'print bla'"));

my ($result, $size) = Gnome2::VFS -> get_volume_free_space(Gnome2::VFS::URI -> new("file://" . cwd()));
is($result, "ok");
like($size, qr/^\d+$/);

ok(Gnome2::VFS -> is_primary_thread());

###############################################################################

Gnome2::VFS -> shutdown();
