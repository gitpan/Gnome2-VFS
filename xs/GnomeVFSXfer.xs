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
 * $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/xs/GnomeVFSXfer.xs,v 1.10 2003/11/28 20:50:30 kaffeetisch Exp $
 */

#include "vfs2perl.h"
#include <gperl_marshal.h>

/* ------------------------------------------------------------------------- */

SV *
newSVGnomeVFSXferProgressInfo (GnomeVFSXferProgressInfo *info)
{
	HV * hv = newHV ();

	if (info) {
		hv_store (hv, "status", 6, newSVGnomeVFSXferProgressStatus (info->status), 0);
		hv_store (hv, "vfs_status", 10, newSVGnomeVFSResult (info->vfs_status), 0);
		hv_store (hv, "phase", 5, newSVGnomeVFSXferPhase (info->phase), 0);
		hv_store (hv, "file_index", 10, newSVuv (info->file_index), 0);
		hv_store (hv, "files_total", 11, newSVuv (info->files_total), 0);
		hv_store (hv, "bytes_total", 11, newSVuv (info->bytes_total), 0);
		hv_store (hv, "file_size", 9, newSVuv (info->file_size), 0);
		hv_store (hv, "bytes_copied", 12, newSVuv (info->bytes_copied), 0);
		hv_store (hv, "total_bytes_copied", 18, newSVuv (info->total_bytes_copied), 0);
		hv_store (hv, "top_level_item", 14, newSVuv (info->top_level_item), 0);

		if (info->source_name)
			hv_store (hv, "source_name", 11, newSVGChar (info->source_name), 0);

		if (info->target_name)
			hv_store (hv, "target_name", 11, newSVGChar (info->target_name), 0);

		if (info->duplicate_count)
			hv_store (hv, "duplicate_count", 15, newSViv (info->duplicate_count), 0);

		/* FIXME: add a version check once the fix from teuf makes it
		          into an official release. */
		if (info->duplicate_name && info->phase != GNOME_VFS_XFER_PHASE_COMPLETED)
			hv_store (hv, "duplicate_name", 14, newSVGChar (info->duplicate_name), 0);
	}

	return newRV_noinc ((SV*) hv);
}

/* ------------------------------------------------------------------------- */

gint
sv_to_int (GType type, SV *sv)
{
	int n;

	if (! gperl_try_convert_enum (type, sv, &n))
		croak ("erroneous return value");

	return n;
}

GPerlCallback *
vfs2perl_xfer_progress_callback_create (SV *func, SV *data)
{
	return gperl_callback_new (func, data, 0, NULL, G_TYPE_INT);
}

gint
vfs2perl_xfer_progress_callback (GnomeVFSXferProgressInfo *info,
                                 GPerlCallback *callback)
{
	gint retval;

	dGPERL_CALLBACK_MARSHAL_SP;
	GPERL_CALLBACK_MARSHAL_INIT (callback);

	ENTER;
	SAVETMPS;

	PUSHMARK (SP);

	EXTEND (SP, 1);
	PUSHs (sv_2mortal (newSVGnomeVFSXferProgressInfo (info)));
	if (callback->data)
		XPUSHs (sv_2mortal (newSVsv (callback->data)));

	PUTBACK;

	call_sv (callback->func, G_SCALAR);

	SPAGAIN;

	if (info->status == GNOME_VFS_XFER_PROGRESS_STATUS_VFSERROR)
		retval = sv_to_int (VFS2PERL_GNOME_TYPE_VFS_XFER_ERROR_ACTION, POPs);
	else if (info->status == GNOME_VFS_XFER_PROGRESS_STATUS_OVERWRITE)
		retval = sv_to_int (VFS2PERL_GNOME_TYPE_VFS_XFER_OVERWRITE_ACTION, POPs);
	else
		retval = POPi;

	PUTBACK;
	FREETMPS;
	LEAVE;

	return retval;
}

/* ------------------------------------------------------------------------- */

MODULE = Gnome2::VFS::Xfer	PACKAGE = Gnome2::VFS::Xfer	PREFIX = gnome_vfs_xfer_

# FIXME: these function names are UGLY.

##  GnomeVFSResult gnome_vfs_xfer_uri (const GnomeVFSURI *source_uri, const GnomeVFSURI *target_uri, GnomeVFSXferOptions xfer_options, GnomeVFSXferErrorMode error_mode, GnomeVFSXferOverwriteMode overwrite_mode, GnomeVFSXferProgressCallback progress_callback, gpointer data) 
GnomeVFSResult
gnome_vfs_xfer_uri (class, source_uri, target_uri, xfer_options, error_mode, overwrite_mode, func, data=NULL)
	const GnomeVFSURI *source_uri
	const GnomeVFSURI *target_uri
	GnomeVFSXferOptions xfer_options
	GnomeVFSXferErrorMode error_mode
	GnomeVFSXferOverwriteMode overwrite_mode
	SV *func
	SV *data
    PREINIT:
	GPerlCallback *callback;
    CODE:
	callback = vfs2perl_xfer_progress_callback_create (func, data);

	RETVAL = gnome_vfs_xfer_uri (source_uri,
	                             target_uri,
	                             xfer_options,
	                             error_mode,
	                             overwrite_mode,
	                             (GnomeVFSXferProgressCallback)
	                               vfs2perl_xfer_progress_callback,
	                             callback);

	gperl_callback_destroy (callback);
    OUTPUT:
	RETVAL

##  GnomeVFSResult gnome_vfs_xfer_uri_list (const GList *source_uri_list, const GList *target_uri_list, GnomeVFSXferOptions xfer_options, GnomeVFSXferErrorMode error_mode, GnomeVFSXferOverwriteMode overwrite_mode, GnomeVFSXferProgressCallback progress_callback, gpointer data) 
GnomeVFSResult
gnome_vfs_xfer_uri_list (class, source_ref, target_ref, xfer_options, error_mode, overwrite_mode, func, data=NULL)
	SV *source_ref
	SV *target_ref
	GnomeVFSXferOptions xfer_options
	GnomeVFSXferErrorMode error_mode
	GnomeVFSXferOverwriteMode overwrite_mode
	SV *func
	SV *data
    PREINIT:
	GList *source_uri_list;
	GList *target_uri_list;
	GPerlCallback *callback;
    CODE:
	source_uri_list = SvGnomeVFSURIGList (source_ref);
	target_uri_list = SvGnomeVFSURIGList (target_ref);

	callback = vfs2perl_xfer_progress_callback_create (func, data);

	RETVAL = gnome_vfs_xfer_uri_list ((const GList *) source_uri_list,
	                                  (const GList *) target_uri_list,
	                                  xfer_options,
	                                  error_mode,
	                                  overwrite_mode,
	                                  (GnomeVFSXferProgressCallback)
	                                    vfs2perl_xfer_progress_callback,
	                                  callback);

	gperl_callback_destroy (callback);

	g_list_free (source_uri_list);
	g_list_free (target_uri_list);
    OUTPUT:
	RETVAL

##  GnomeVFSResult gnome_vfs_xfer_delete_list (const GList *source_uri_list, GnomeVFSXferErrorMode error_mode, GnomeVFSXferOptions xfer_options, GnomeVFSXferProgressCallback progress_callback, gpointer data) 
GnomeVFSResult
gnome_vfs_xfer_delete_list (class, source_ref, error_mode, xfer_options, func, data=NULL)
	SV *source_ref
	GnomeVFSXferErrorMode error_mode
	GnomeVFSXferOptions xfer_options
	SV *func
	SV *data
    PREINIT:
	GList *source_uri_list;
	GPerlCallback *callback;
    CODE:
	source_uri_list = SvGnomeVFSURIGList (source_ref);

	callback = vfs2perl_xfer_progress_callback_create (func, data);

	RETVAL = gnome_vfs_xfer_delete_list ((const GList *) source_uri_list,
	                                     error_mode,
	                                     xfer_options,
	                                     (GnomeVFSXferProgressCallback)
	                                       vfs2perl_xfer_progress_callback,
	                                     callback);

	gperl_callback_destroy (callback);

	g_list_free (source_uri_list);
    OUTPUT:
	RETVAL
