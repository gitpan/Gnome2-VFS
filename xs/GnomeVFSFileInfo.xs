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
 * $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/xs/GnomeVFSFileInfo.xs,v 1.9 2005/02/10 21:21:17 kaffeetisch Exp $
 */

#include "vfs2perl.h"

/* ------------------------------------------------------------------------- */

#ifdef VFS2PERL_BROKEN_FILE_PERMISSIONS

/*
 * GnomeVFSFilePermissions is supposed to be a GFlags type, but on some
 * early releases, it appears that glib-mkenums misread the definition and
 * registered it as a GEnum type, instead.  This causes some big problems
 * for using the type in the bindings; if we do nothing, we get incessant
 * assertions that the type is not a GFlags type, but if we register it as
 * an enum instead, we get errors because bit-combination values aren't
 * part of the enum set.  The only real solution is to hijack the type
 * macro to point to our own special get_type and registration which does
 * it properly.
 *
 * these are the values that are actually defined in my header for 2.0.2 
 * on redhat 8.0.  some of the values present in later versions are missing.
 *
 * - muppet, 18 nov 03
 */
static const GFlagsValue file_perms_values[] = {
  { GNOME_VFS_PERM_SUID,        "GNOME_VFS_PERM_SUID",        "suid"        },
  { GNOME_VFS_PERM_SGID,        "GNOME_VFS_PERM_SGID",        "sgid"        },  
  { GNOME_VFS_PERM_STICKY,      "GNOME_VFS_PERM_STICKY",      "sticky"      },
  { GNOME_VFS_PERM_USER_READ,   "GNOME_VFS_PERM_USER_READ",   "user-read"   },
  { GNOME_VFS_PERM_USER_WRITE,  "GNOME_VFS_PERM_USER_WRITE",  "user-write"  },
  { GNOME_VFS_PERM_USER_EXEC,   "GNOME_VFS_PERM_USER_EXEC",   "user-exec"   },
  { GNOME_VFS_PERM_USER_ALL,    "GNOME_VFS_PERM_USER_ALL",    "user-all"    },
  { GNOME_VFS_PERM_GROUP_READ,  "GNOME_VFS_PERM_GROUP_READ",  "group-read"  },
  { GNOME_VFS_PERM_GROUP_WRITE, "GNOME_VFS_PERM_GROUP_WRITE", "group-write" },
  { GNOME_VFS_PERM_GROUP_EXEC,  "GNOME_VFS_PERM_GROUP_EXEC",  "group-exec"  },
  { GNOME_VFS_PERM_GROUP_ALL,   "GNOME_VFS_PERM_GROUP_ALL",   "group-all"   },
  { GNOME_VFS_PERM_OTHER_READ,  "GNOME_VFS_PERM_OTHER_READ",  "other-read"  },
  { GNOME_VFS_PERM_OTHER_WRITE, "GNOME_VFS_PERM_OTHER_WRITE", "other-write" },
  { GNOME_VFS_PERM_OTHER_EXEC,  "GNOME_VFS_PERM_OTHER_EXEC",  "other-exec"  },
  { GNOME_VFS_PERM_OTHER_ALL,   "GNOME_VFS_PERM_OTHER_ALL",   "other-all"   },
};

GType
_vfs2perl_gnome_vfs_file_permissions_get_type (void)
{
	static GType type = 0;

	if (!type)
		type = g_flags_register_static ("VFS2PerlFilePermissions",
		                                file_perms_values);

	return type;
}

#endif /* VFS2PERL_BROKEN_FILE_PERMISSIONS */

/* ------------------------------------------------------------------------- */

#define VFS2PERL_CHECK_AND_STORE(_type, _key, _sv) \
		if (info->valid_fields & _type) \
			hv_store (object, _key, strlen (_key), _sv, 0);

SV *
newSVGnomeVFSFileInfo (GnomeVFSFileInfo *info)
{
	HV *object = newHV ();

	if (info && info->name && info->valid_fields) {
		hv_store (object, "name", 4, newSVpv (info->name, PL_na), 0);
		hv_store (object, "valid_fields", 12, newSVGnomeVFSFileInfoFields (info->valid_fields), 0);

		VFS2PERL_CHECK_AND_STORE (GNOME_VFS_FILE_INFO_FIELDS_TYPE, "type", newSVGnomeVFSFileType (info->type));
		VFS2PERL_CHECK_AND_STORE (GNOME_VFS_FILE_INFO_FIELDS_PERMISSIONS, "permissions", newSVGnomeVFSFilePermissions (info->permissions));
		VFS2PERL_CHECK_AND_STORE (GNOME_VFS_FILE_INFO_FIELDS_FLAGS, "flags", newSVGnomeVFSFileFlags (info->flags));
		VFS2PERL_CHECK_AND_STORE (GNOME_VFS_FILE_INFO_FIELDS_DEVICE, "device", newSViv (info->device));
		VFS2PERL_CHECK_AND_STORE (GNOME_VFS_FILE_INFO_FIELDS_INODE, "inode", newSVuv (info->inode));
		VFS2PERL_CHECK_AND_STORE (GNOME_VFS_FILE_INFO_FIELDS_LINK_COUNT, "link_count", newSVuv (info->link_count));
		VFS2PERL_CHECK_AND_STORE (GNOME_VFS_FILE_INFO_FIELDS_SIZE, "size", newSVGnomeVFSFileSize (info->size));
		VFS2PERL_CHECK_AND_STORE (GNOME_VFS_FILE_INFO_FIELDS_BLOCK_COUNT, "block_count", newSVGnomeVFSFileSize (info->block_count));
		VFS2PERL_CHECK_AND_STORE (GNOME_VFS_FILE_INFO_FIELDS_IO_BLOCK_SIZE, "io_block_size", newSVuv (info->io_block_size));
		VFS2PERL_CHECK_AND_STORE (GNOME_VFS_FILE_INFO_FIELDS_ATIME, "atime", newSViv (info->atime));
		VFS2PERL_CHECK_AND_STORE (GNOME_VFS_FILE_INFO_FIELDS_MTIME, "mtime", newSViv (info->mtime));
		VFS2PERL_CHECK_AND_STORE (GNOME_VFS_FILE_INFO_FIELDS_CTIME, "ctime", newSViv (info->ctime));
		VFS2PERL_CHECK_AND_STORE (GNOME_VFS_FILE_INFO_FIELDS_SYMLINK_NAME, "symlink_name", newSVpv (info->symlink_name, PL_na));
		VFS2PERL_CHECK_AND_STORE (GNOME_VFS_FILE_INFO_FIELDS_MIME_TYPE, "mime_type", newSVpv (info->mime_type, PL_na));

		/* FIXME: what about GNOME_VFS_FILE_INFO_FIELDS_ACCESS? */
	}

	return sv_bless (newRV_noinc ((SV *) object),
	                 gv_stashpv ("Gnome2::VFS::FileInfo", 1));
}

#define VFS2PERL_FETCH_AND_CHECK(_type, _key, _member, _sv) \
		if (hv_exists (hv, _key, strlen (_key))) { \
			value = hv_fetch (hv, _key, strlen (_key), FALSE); \
			if (value) _member = _sv; \
			info->valid_fields |= _type; \
		}

GnomeVFSFileInfo *
SvGnomeVFSFileInfo (SV *object)
{
	HV *hv = (HV *) SvRV (object);
	SV **value;

	GnomeVFSFileInfo *info = gperl_alloc_temp (sizeof (GnomeVFSFileInfo));

	if (object && SvOK (object) && SvROK (object) && SvTYPE (SvRV (object)) == SVt_PVHV) {
		value = hv_fetch (hv, "name", 4, FALSE);
		if (value) info->name = SvPV_nolen (*value);

		info->valid_fields = GNOME_VFS_FILE_INFO_FIELDS_NONE;

		VFS2PERL_FETCH_AND_CHECK (GNOME_VFS_FILE_INFO_FIELDS_TYPE, "type", info->type, SvGnomeVFSFileType (*value));
		VFS2PERL_FETCH_AND_CHECK (GNOME_VFS_FILE_INFO_FIELDS_PERMISSIONS, "permissions", info->permissions, SvGnomeVFSFilePermissions (*value));
		VFS2PERL_FETCH_AND_CHECK (GNOME_VFS_FILE_INFO_FIELDS_FLAGS, "flags", info->flags, SvGnomeVFSFileFlags (*value));
		VFS2PERL_FETCH_AND_CHECK (GNOME_VFS_FILE_INFO_FIELDS_DEVICE, "device", info->device, SvIV (*value));
		VFS2PERL_FETCH_AND_CHECK (GNOME_VFS_FILE_INFO_FIELDS_INODE, "inode", info->inode, SvUV (*value));
		VFS2PERL_FETCH_AND_CHECK (GNOME_VFS_FILE_INFO_FIELDS_LINK_COUNT, "link_count", info->link_count, SvUV (*value));
		VFS2PERL_FETCH_AND_CHECK (GNOME_VFS_FILE_INFO_FIELDS_SIZE, "size", info->size, SvGnomeVFSFileSize (*value));
		VFS2PERL_FETCH_AND_CHECK (GNOME_VFS_FILE_INFO_FIELDS_BLOCK_COUNT, "block_count", info->block_count, SvGnomeVFSFileSize (*value));
		VFS2PERL_FETCH_AND_CHECK (GNOME_VFS_FILE_INFO_FIELDS_IO_BLOCK_SIZE, "io_block_size", info->io_block_size, SvUV (*value));
		VFS2PERL_FETCH_AND_CHECK (GNOME_VFS_FILE_INFO_FIELDS_ATIME, "atime", info->atime, SvIV (*value));
		VFS2PERL_FETCH_AND_CHECK (GNOME_VFS_FILE_INFO_FIELDS_MTIME, "mtime", info->mtime, SvIV (*value));
		VFS2PERL_FETCH_AND_CHECK (GNOME_VFS_FILE_INFO_FIELDS_CTIME, "ctime", info->ctime, SvIV (*value));
		VFS2PERL_FETCH_AND_CHECK (GNOME_VFS_FILE_INFO_FIELDS_SYMLINK_NAME, "symlink_name", info->symlink_name, SvPV_nolen (*value));
		VFS2PERL_FETCH_AND_CHECK (GNOME_VFS_FILE_INFO_FIELDS_MIME_TYPE, "mime_type", info->mime_type, SvPV_nolen (*value));

		/* FIXME: what about GNOME_VFS_FILE_INFO_FIELDS_ACCESS? */
	}

	return info;
}

/* ------------------------------------------------------------------------- */

MODULE = Gnome2::VFS::FileInfo	PACKAGE = Gnome2::VFS::FileInfo	PREFIX = gnome_vfs_file_info_

=for apidocs

Creates a new GnomeVFSFileInfo object from I<hash_ref> for use with
Gnome2::VFS::FileInfo::matches, for example.  Normally, you can always directly
use a hash reference if you're asked for a GnomeVFSFileInfo.

=cut
GnomeVFSFileInfo *
gnome_vfs_file_info_new (class, hash_ref)
	SV *hash_ref
    CODE:
	/* All this really doesn't do much more than just bless the reference,
	   because on the way out, the struct will be converted to a hash
	   reference again.  Not really efficient, but future-safe. */
	RETVAL = SvGnomeVFSFileInfo (hash_ref);
    OUTPUT:
	RETVAL

##  gboolean gnome_vfs_file_info_matches (const GnomeVFSFileInfo *a, const GnomeVFSFileInfo *b) 
gboolean
gnome_vfs_file_info_matches (a, b)
	const GnomeVFSFileInfo *a
	const GnomeVFSFileInfo *b

##  const char * gnome_vfs_file_info_get_mime_type (GnomeVFSFileInfo *info)
const char *
gnome_vfs_file_info_get_mime_type (info)
	GnomeVFSFileInfo *info
