#!/usr/bin/perl -w
use strict;

# $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/genmaps.pl,v 1.2 2003/11/28 20:50:27 kaffeetisch Exp $

my @types = ();
my @dirs = (
  '/usr/include/gnome-vfs-2.0/libgnomevfs',
  'build',
);

foreach my $dir (@dirs) {
	my @lines = `grep _TYPE $dir/*.h | grep get_type`;
	foreach (@lines) {
		chomp;
		s/^.*\s([A-Z][A-Z0-9_]*_TYPE[A-Z0-9_]*)\s.*$/$1/;
		# print "$1\n";
		push @types, $_;
	}
}



open FOO, "> foo.c";
select FOO;

print '#include <stdio.h>
#include <gtk/gtk.h>
#include <libgnomevfs/gnome-vfs-types.h>
#include <libgnomevfs/gnome-vfs-utils.h>
#include <libgnomevfs/gnome-vfs-monitor.h>
#include <libgnomevfs/gnome-vfs-mime-handlers.h>
#include <libgnomevfs/gnome-vfs-mime-monitor.h>
#include <libgnomevfs/gnome-vfs-directory.h>
#include "build/vfs2perl-gtypes.h"

const char * find_base (GType gtype)
{
	if (g_type_is_a (gtype, GTK_TYPE_OBJECT))
		return "GtkObject";
	if (g_type_is_a (gtype, G_TYPE_OBJECT))
		return "GObject";
	if (g_type_is_a (gtype, G_TYPE_BOXED))
		return "GBoxed";
	if (g_type_is_a (gtype, G_TYPE_FLAGS))
		return "GFlags";
	if (g_type_is_a (gtype, G_TYPE_ENUM))
		return "GEnum";
	if (g_type_is_a (gtype, G_TYPE_INTERFACE))
		return "GInterface";
	if (g_type_is_a (gtype, G_TYPE_STRING))
		return "GString";
	{
	GType parent = gtype;
	while (parent != 0) {
		gtype = parent;
		parent = g_type_parent (gtype);
	}
	return g_type_name (gtype);
	}
	return "-";
}

int main (int argc, char * argv [])
{
	g_type_init ();
';

foreach (@types) {
	print '#ifdef '.$_.'
{
        GType gtype = '.$_.';
        printf ("%s\t%s\t%s\n",
                "'.$_.'", 
		g_type_name (gtype),
		find_base (gtype));
}
#endif /* '.$_.' */
';
}

print '
	return 0;
}
';

close FOO;
select STDOUT;

system 'gcc -DGTK_DISABLE_DEPRECATED -DGNOME_DISABLE_DEPRECATED -Wall -o foo foo.c build/vfs2perl-gtypes.c `pkg-config libgnomeui-2.0 --cflags --libs`'
	and die "couldn't compile helper program";

# these are matched in order; for example, GnomePrinter must test before
# GnomePrint to avoid matching the wrong thing.
my @packagemap = (
  [ GnomeVFSMIME => 'Gnome2::VFS::Mime' ],
  [ GnomeVFSURI  => 'Gnome2::VFS::URI' ],
  [ GnomeVFS     => 'Gnome2::VFS' ],
  [ Gnome        => 'Gnome2' ], # fallback
);

foreach (`./foo`) {
  chomp;

  my @typemap = split;
  my $prefix = 'Gnome';
  my $pkg = 'Gnome2';

  foreach my $mapping (@packagemap) {
    my $type = $mapping->[0];
    if ($typemap[1] =~ /^$type/) {
      $prefix = $mapping->[0];
      $pkg = $mapping->[1];
      last;
    }
  }

  (my $fullname = $typemap[1]) =~ s/^$prefix/$pkg\::/;
  $fullname =~ s/\::$//;
  print join("\t", @typemap, $fullname), "\n";
}
