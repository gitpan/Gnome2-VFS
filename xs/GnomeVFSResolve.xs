/*
 * Copyright (C) 2004 by the gtk2-perl team
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/xs/GnomeVFSResolve.xs,v 1.1 2004/07/29 17:36:03 kaffeetisch Exp $
 */

#include "vfs2perl.h"

MODULE = Gnome2::VFS::Resolve	PACKAGE = Gnome2::VFS	PREFIX = gnome_vfs_

##  GnomeVFSResult gnome_vfs_resolve (const char *hostname, GnomeVFSResolveHandle **handle)
void
gnome_vfs_resolve (class, hostname)
	const char *hostname
    PREINIT:
	GnomeVFSResult result;
	GnomeVFSResolveHandle *handle = NULL;
    PPCODE:
	result = gnome_vfs_resolve (hostname, &handle);

	PUSHs (sv_2mortal (newSVGnomeVFSResult (result)));

	if (result == GNOME_VFS_OK) {
		XPUSHs (sv_2mortal (newSVGnomeVFSResolveHandle (handle)));
	}

MODULE = Gnome2::VFS::Resolve	PACKAGE = Gnome2::VFS::Resolve::Handle	PREFIX = gnome_vfs_resolve_

##  gboolean gnome_vfs_resolve_next_address (GnomeVFSResolveHandle *handle, GnomeVFSAddress **address)
GnomeVFSAddress_ornull *
gnome_vfs_resolve_next_address (handle)
	GnomeVFSResolveHandle *handle
    PREINIT:
	GnomeVFSAddress *address = NULL;
    CODE:
	RETVAL = gnome_vfs_resolve_next_address (handle, &address) ?
	           address :
	           NULL;
    OUTPUT:
	RETVAL

##  void gnome_vfs_resolve_reset_to_beginning (GnomeVFSResolveHandle *handle)
void
gnome_vfs_resolve_reset_to_beginning (handle)
	GnomeVFSResolveHandle *handle
