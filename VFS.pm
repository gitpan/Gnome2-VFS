# $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/VFS.pm,v 1.26 2005/03/07 21:18:50 kaffeetisch Exp $

package Gnome2::VFS;

use 5.008;
use strict;
use warnings;

use Glib;

require DynaLoader;

our @ISA = qw(DynaLoader);

our $VERSION = '1.020';

sub import {
  my $self = shift();

  foreach (@_) {
    if (/^-?init$/) {
      $self -> init();
    }
    else {
      $self -> VERSION($_);
    }
  }
}

sub dl_load_flags { $^O eq 'darwin' ? 0x00 : 0x01 }

Gnome2::VFS -> bootstrap($VERSION);

# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Gnome2::VFS - Perl interface to the 2.x series of the GNOME VFS library

=head1 SYNOPSIS

  use Gnome2::VFS;

  sub die_already {
    my ($action) = @_;
    die("An error occured while $action.\n");
  }

  die_already("initializing GNOME VFS") unless (Gnome2::VFS -> init());

  my $source = "http://www.perldoc.com/about.html";
  my ($result, $handle, $info);

  # Open a connection to Perldoc.
  ($result, $handle) = Gnome2::VFS -> open($source, "read");
  die_already("opening connection to '$source'")
    unless ($result eq "ok");

  # Get the file information.
  ($result, $info) = $handle -> get_file_info("default");
  die_already("retrieving information about '$source'")
    unless ($result eq "ok");

  # Read the content.
  my $bytes = $info -> { size };

  my $bytes_read = 0;
  my $buffer = "";

  do {
    my ($tmp_buffer, $tmp_bytes_read);

    ($result, $tmp_bytes_read, $tmp_buffer) =
      $handle -> read($bytes - $bytes_read);

    $buffer .= $tmp_buffer;
    $bytes_read += $tmp_bytes_read;
  } while ($result eq "ok" and $bytes_read < $bytes);

  die_already("reading $bytes bytes from '$source'")
    unless ($result eq "ok" && $bytes_read == $bytes);

  # Close the connection.
  $result = $handle -> close();
  die_already("closing connection to '$source'")
    unless ($result eq "ok");

  # Create and open the target.
  my $target = "/tmp/" . $info -> { name };
  my $uri = Gnome2::VFS::URI -> new($target);

  ($result, $handle) = $uri -> create("write", 1, 0644);
  die_already("creating '$target'") unless ($result eq "ok");

  # Write to it.
  my $bytes_written;

  ($result, $bytes_written) = $handle -> write($buffer, $bytes);
  die_already("writing $bytes bytes to '$target'")
    unless ($result eq "ok" && $bytes_written == $bytes);

  # Close the target.
  $result = $handle -> close();
  die_already("closing '$target'") unless ($result eq "ok");

  Gnome2::VFS -> shutdown();

=head1 ABSTRACT

This module allows you to interface with the GNOME Virtual File System library.
It provides the means to transparently access files on all kinds of
filesystems.

=head1 DESCRIPTION

Since this module tries to stick very closely to the C API, the documentation
found at

  http://developer.gnome.org/doc/API/2.0/gnome-vfs-2.0/

is the canonical reference.

In addition to that, there's also the automatically generated API
documentation: L<Gnome2::VFS::index>(3pm).

The mapping described in L<Gtk2::api>(3pm) also applies to this module.

To discuss this module, ask questions and flame/praise the authors, join
gtk-perl-list@gnome.org at lists.gnome.org.

=head1 KNOWN BUGS

There are some memory leaks especially with respect to callbacks.  This mainly
affects GnomeVFSAsync as well as some parts of GnomeVFSXfer and GnomeVFSOps.
GnomeVFSMime leaks some list data.

GnomeVFSAsync is also known to crash under certain conditions when there are
many concurrent transfers.

=head1 SEE ALSO

L<perl>(1), L<Gnome2::VFS::index>(3pm), L<Glib>(3pm), L<Gtk2>(3pm),
L<Gtk2::api>(3pm).

=head1 AUTHOR

Torsten Schoenfeld E<lt>kaffeetisch@web.deE<gt>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2003-2005 by the gtk2-perl team (see the file AUTHORS)

This library is free software; you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation; either version 2.1 of the License, or (at your option) any
later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
details.

You should have received a copy of the GNU Lesser General Public License along
with this library; if not, write to the Free Software Foundation, Inc.,
59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

=cut
