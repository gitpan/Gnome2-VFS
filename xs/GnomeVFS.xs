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
 * $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/xs/GnomeVFS.xs,v 1.16 2003/12/19 17:26:26 kaffeetisch Exp $
 */

#include "vfs2perl.h"

/* ------------------------------------------------------------------------- */

SV *
newSVGnomeVFSFileSize (GnomeVFSFileSize size)
{
	return newSVuv (size);
}

GnomeVFSFileSize
SvGnomeVFSFileSize (SV *size)
{
	return SvUV (size);
}

SV *
newSVGnomeVFSFileOffset (GnomeVFSFileOffset offset)
{
	return newSVuv (offset);
}

GnomeVFSFileOffset
SvGnomeVFSFileOffset (SV *offset)
{
	return SvUV (offset);
}

/* ------------------------------------------------------------------------- */

GList *
SvPVGList (SV *ref)
{
	int i;

	AV *array;
	SV **value;

	GList *list = NULL;

	if (! (SvRV (ref) && SvTYPE (SvRV (ref)) == SVt_PVAV))
		croak ("URI list has to be a reference to an array");

	array = (AV *) SvRV (ref);

	for (i = 0; i <= av_len (array); i++)
		if ((value = av_fetch (array, i, 0)) && SvOK (*value))
			list = g_list_append(list, SvPV_nolen (*value));

	return list;
}

GList *
SvGnomeVFSURIGList (SV *ref)
{
	int i;

	AV *array;
	SV **value;

	GList *list = NULL;

	if (! (SvRV (ref) && SvTYPE (SvRV (ref)) == SVt_PVAV))
		croak ("URI list has to be a reference to an array");

	array = (AV *) SvRV (ref);

	for (i = 0; i <= av_len (array); i++)
		if ((value = av_fetch (array, i, 0)) && SvOK (*value))
			list = g_list_append(list, SvGnomeVFSURI (*value));

	return list;
}

char **SvEnvArray (SV *ref)
{
	char **result = NULL;

	if (SvOK (ref))
		if (SvRV (ref) && SvTYPE (SvRV (ref)) == SVt_PVAV) {
			AV *array = (AV *) SvRV (ref);
			SV **string;

			int i, length = av_len (array);
			result = g_new0 (char *, length + 2);

			for (i = 0; i <= length; i++)
				if ((string = av_fetch (array, i, 0)) && SvOK (*string))
					result[i] = SvPV_nolen (*string);

			result[length + 1] = NULL;
		}
		else
			croak ("the environment parameter must be an array reference");

	return result;
}

SV *
newSVGnomeVFSFileInfoGList (GList *list)
{
	AV *array = newAV ();

	for (; list != NULL; list = list->next)
		av_push (array, newSVGnomeVFSFileInfo (list->data));

	return newRV_noinc ((SV *) array);
}

SV *
newSVGnomeVFSGetFileInfoResultGList (GList *list)
{
	AV *array = newAV ();

	for (; list != NULL; list = list->next) {
		HV *hash = newHV ();
		GnomeVFSGetFileInfoResult* result = list->data;

		gnome_vfs_uri_ref (result->uri);

		hv_store (hash, "uri", 3, newSVGnomeVFSURI (result->uri), 0);
		hv_store (hash, "result", 6, newSVGnomeVFSResult (result->result), 0);
		hv_store (hash, "file_info", 9, newSVGnomeVFSFileInfo (result->file_info), 0);

		av_push (array, newRV_noinc ((SV *) hash));
	}

	return newRV_noinc ((SV *) array);
}

SV *
newSVGnomeVFSFindDirectoryResultGList (GList *list)
{
	AV *array = newAV ();

	for (; list != NULL; list = list->next) {
		HV *hash = newHV ();
		GnomeVFSFindDirectoryResult* result = list->data;

		hv_store (hash, "result", 6, newSVGnomeVFSResult (result->result), 0);

		if (result->uri) {
			gnome_vfs_uri_ref (result->uri);
			hv_store (hash, "uri", 3, newSVGnomeVFSURI (result->uri), 0);
		}

		av_push (array, newRV_noinc ((SV *) hash));
	}

	return newRV_noinc ((SV *) array);
}

/* ------------------------------------------------------------------------- */

MODULE = Gnome2::VFS	PACKAGE = Gnome2::VFS	PREFIX = gnome_vfs_

=for object Gnome2::VFS::main

=cut

BOOT:
{
#include "register.xsh"
#include "boot.xsh"
	gperl_handle_logs_for ("libgnomevfs");
}

=for apidoc

Returns the major, minor and micro version numbers of GnomeVFS.

=cut
void
gnome_vfs_get_version_info (class)
    PPCODE:
	PERL_UNUSED_VAR (ax);
	EXTEND (SP, 3);
	PUSHs (sv_2mortal (newSViv (VFS_MAJOR_VERSION)));
	PUSHs (sv_2mortal (newSViv (VFS_MINOR_VERSION)));
	PUSHs (sv_2mortal (newSViv (VFS_MICRO_VERSION)));

bool
gnome_vfs_check_version (class, major, minor, micro)
	int major
	int minor
	int micro
    CODE:
	RETVAL = VFS_CHECK_VERSION (major, minor, micro);
    OUTPUT:
	RETVAL

=for apidoc

Returns a GnomeVFSResult and a GnomeVFSURI.

=cut
##  GnomeVFSResult gnome_vfs_find_directory (GnomeVFSURI *near_uri, GnomeVFSFindDirectoryKind kind, GnomeVFSURI **result, gboolean create_if_needed, gboolean find_if_needed, guint permissions)
void
gnome_vfs_find_directory (class, near_uri, kind, create_if_needed, find_if_needed, permissions)
	GnomeVFSURI *near_uri
	GnomeVFSFindDirectoryKind kind
	gboolean create_if_needed
	gboolean find_if_needed
	guint permissions
    PREINIT:
	GnomeVFSResult result;
	GnomeVFSURI *result_uri;
    PPCODE:
	result = gnome_vfs_find_directory (near_uri, kind, &result_uri, create_if_needed, find_if_needed, permissions);
	EXTEND (sp, 2);
	PUSHs (sv_2mortal (newSVGnomeVFSResult (result)));
	PUSHs (sv_2mortal (newSVGnomeVFSURI (result_uri)));

##  const char *gnome_vfs_result_to_string (GnomeVFSResult result)
const char *
gnome_vfs_result_to_string (class, result)
	GnomeVFSResult result
    C_ARGS:
	result
 
##  char *gnome_vfs_get_mime_type (const char *text_uri)
char *
gnome_vfs_get_mime_type (class, text_uri)
	const char *text_uri
    C_ARGS:
	text_uri
    CLEANUP:
	g_free (RETVAL);

###  const char *gnome_vfs_get_mime_type_for_data (gconstpointer data, int data_size)
#const char *
#gnome_vfs_get_mime_type_for_data (data, data_size)
#	gconstpointer data
#	int data_size
