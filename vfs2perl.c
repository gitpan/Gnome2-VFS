/*
 * Copyright (C) 2003 by the gtk2-perl team
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
 * $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/vfs2perl.c,v 1.1 2003/11/23 21:48:32 kaffeetisch Exp $
 */

#include "vfs2perl.h"

GType
vfs2perl_gnome_vfs_uri_get_type (void)
{
	static GType t = 0;
	if (!t)
		t = g_boxed_type_register_static ("GnomeVFSURI",
		      (GBoxedCopyFunc) gnome_vfs_uri_ref,
		      (GBoxedFreeFunc) gnome_vfs_uri_unref);
	return t;
}

GType
vfs2perl_gnome_vfs_handle_get_type (void)
{
	static GType t = 0;
	if (!t)
		t = g_boxed_type_register_static ("GnomeVFSHandle",
		      (GBoxedCopyFunc) g_boxed_copy,
		      (GBoxedFreeFunc) g_boxed_free);
	return t;
}

GType
vfs2perl_gnome_vfs_monitor_handle_get_type (void)
{
	static GType t = 0;
	if (!t)
		t = g_boxed_type_register_static ("GnomeVFSMonitorHandle",
		      (GBoxedCopyFunc) g_boxed_copy,
		      (GBoxedFreeFunc) g_boxed_free);
	return t;
}

GType
vfs2perl_gnome_vfs_directory_handle_get_type (void)
{
	static GType t = 0;
	if (!t)
		t = g_boxed_type_register_static ("GnomeVFSDirectoryHandle",
		      (GBoxedCopyFunc) g_boxed_copy,
		      (GBoxedFreeFunc) g_boxed_free);
	return t;
}

GType
vfs2perl_gnome_vfs_async_handle_get_type (void)
{
	static GType t = 0;
	if (!t)
		t = g_boxed_type_register_static ("GnomeVFSAsyncHandle",
		      (GBoxedCopyFunc) g_boxed_copy,
		      (GBoxedFreeFunc) g_boxed_free);
	return t;
}
