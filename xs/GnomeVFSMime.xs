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
 * $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/xs/GnomeVFSMime.xs,v 1.2 2003/11/29 03:05:38 kaffeetisch Exp $
 */

#include "vfs2perl.h"

/* ------------------------------------------------------------------------- */

const char *
SvGnomeVFSMimeType (SV *object)
{
	MAGIC *mg;

	if (!object || !SvOK (object) || !SvROK (object) || !(mg = mg_find (SvRV (object), PERL_MAGIC_ext)))
		return NULL;

	return (const char *) mg->mg_ptr;
}

SV *
newSVGnomeVFSMimeType (const char *mime_type)
{
	SV *rv;
	HV *stash;
	SV *object = (SV *) newHV ();

	sv_magic (object, 0, PERL_MAGIC_ext, mime_type, 0);

	rv = newRV_noinc (object);
	stash = gv_stashpv ("Gnome2::VFS::Mime::Type", 1);

	return sv_bless (rv, stash);
}

/* ------------------------------------------------------------------------- */

SV *
newSVGnomeVFSMimeApplication (GnomeVFSMimeApplication *application)
{
	HV *hash = newHV ();

	if (application == NULL)
		return &PL_sv_undef;

	hv_store (hash, "id", 2, newSVpv (application->id, PL_na), 0);
	hv_store (hash, "name", 4, newSVpv (application->name, PL_na), 0);
	hv_store (hash, "command", 7, newSVpv (application->command, PL_na), 0);
	hv_store (hash, "can_open_multiple_files", 23, newSVuv (application->can_open_multiple_files), 0);
	hv_store (hash, "expects_uris", 12, newSVGnomeVFSMimeApplicationArgumentType (application->expects_uris), 0);
	hv_store (hash, "requires_terminal", 17, newSVuv (application->requires_terminal), 0);

	if (application->supported_uri_schemes != NULL) {
		AV *array = newAV ();
		GList *i;

		for (i = application->supported_uri_schemes; i != NULL; i = i->next)
			av_push (array, newSVpv (i->data, PL_na));

		hv_store (hash, "supported_uri_schemes", 21, newRV_noinc ((SV *) array), 0);
	}

	gnome_vfs_mime_application_free (application);

	return sv_bless (newRV_noinc ((SV *) hash),
	                 gv_stashpv ("Gnome2::VFS::Mime::Application", 1));
}

GnomeVFSMimeApplication *
SvGnomeVFSMimeApplication (SV *object)
{
	GnomeVFSMimeApplication *application = gperl_alloc_temp (sizeof (GnomeVFSMimeApplication));

	if (object && SvOK (object) && SvROK (object) && SvTYPE (SvRV (object)) == SVt_PVHV) {
		HV *hv = (HV *) SvRV (object);
		SV **value;

		value = hv_fetch (hv, "id", 2, FALSE);
		if (value) application->id = SvPV_nolen (*value);

		value = hv_fetch (hv, "name", 4, FALSE);
		if (value) application->name = SvPV_nolen (*value);

		value = hv_fetch (hv, "command", 7, FALSE);
		if (value) application->command = SvPV_nolen (*value);

		value = hv_fetch (hv, "can_open_multiple_files", 23, FALSE);
		if (value) application->can_open_multiple_files = SvUV (*value);

		value = hv_fetch (hv, "expects_uris", 12, FALSE);
		if (value) application->expects_uris = SvGnomeVFSMimeApplicationArgumentType (*value);

		value = hv_fetch (hv, "requires_terminal", 17, FALSE);
		if (value) application->requires_terminal = SvUV (*value);

		value = hv_fetch (hv, "supported_uri_schemes", 21, FALSE);
		if (*value && SvOK (*value) && SvROK (*value) && SvTYPE (SvRV (*value)) == SVt_PVAV) {
			AV *array = (AV *) SvRV (*value);
			int i;

			application->supported_uri_schemes = NULL;

			for (i = 0; i <= av_len (array); i++) {
				value = av_fetch (array, i, 0);

				if (value)
					application->supported_uri_schemes = g_list_append (application->supported_uri_schemes, SvPV_nolen (*value));
			}
		}
	}

	return application;
}

/* ------------------------------------------------------------------------- */

/*

struct Bonobo_ServerInfo_type
{
   Bonobo_ImplementationID iid;
   CORBA_string server_type;
   CORBA_string location_info;
   CORBA_string username;
   CORBA_string hostname;
   CORBA_string domain;
   CORBA_sequence_Bonobo_ActivationProperty props;
};

typedef struct {
        GnomeVFSMimeActionType action_type;
        union {
                Bonobo_ServerInfo *component;
                void *dummy_component;
                GnomeVFSMimeApplication *application;
        } action;
} GnomeVFSMimeAction;

SV *
newSVGnomeVFSMimeAction (GnomeVFSMimeAction *action)
{
	...
}

*/

/* ------------------------------------------------------------------------- */

MODULE = Gnome2::VFS::Mime	PACKAGE = Gnome2::VFS::Mime	PREFIX = gnome_vfs_mime_

# FIXME, FIXME, FIXME: why does it crash?
##  gboolean gnome_vfs_mime_id_in_application_list (const char *id, GList *applications) 
#############gboolean
#############gnome_vfs_mime_id_in_application_list (class, id, first_application, ...)
#############	const char *id
#############    PREINIT:
#############	int i;
#############	GList *applications = NULL;
#############    CODE:
#############	for (i = 2; i < items; i++)
#############		applications = g_list_append (applications, SvGnomeVFSMimeApplication (ST (i)));
#############
#############	RETVAL = gnome_vfs_mime_id_in_application_list (id, applications);
#############
#############	gnome_vfs_mime_application_list_free (applications);
#############    OUTPUT:
#############	RETVAL

# FIXME, FIXME, FIXME: why does it crash?
##  GList * gnome_vfs_mime_remove_application_from_list (GList *applications, const char *application_id, gboolean *did_remove) 
#############void
#############gnome_vfs_mime_remove_application_from_list (class, application_id, first_application, ...)
#############	const char *application_id
#############    PREINIT:
#############	int i;
#############	GList *applications = NULL, *result, *j;
#############	gboolean did_remove;
#############    PPCODE:
#############	for (i = 2; i < items; i++)
#############		applications = g_list_append (applications, SvGnomeVFSMimeApplication (ST (i)));
#############
#############	result = gnome_vfs_mime_remove_application_from_list (applications, application_id, &did_remove);
#############
#############	EXTEND (sp, 1);
#############	PUSHs (sv_2mortal (newSVuv (did_remove)));
#############
#############	for (j = result; j != NULL; j = j->next)
#############		XPUSHs (sv_2mortal (newSVGnomeVFSMimeApplication (j->data)));
#############
#############	gnome_vfs_mime_application_list_free (applications);
#############	g_list_free (result);

# FIXME, FIXME, FIXME: why does it crash?
###############  GList * gnome_vfs_mime_id_list_from_application_list (GList *applications) 
#############void
#############gnome_vfs_mime_id_list_from_application_list (class, fist_application, ...)
#############    PREINIT:
#############	int i;
#############	GList *applications = NULL, *ids, *j;
#############    PPCODE:
#############	for (i = 1; i < items; i++)
#############		applications = g_list_append (applications, SvGnomeVFSMimeApplication (ST (i)));
#############
#############	ids = gnome_vfs_mime_id_list_from_application_list (applications);
#############
#############	for (j = ids; j != NULL; j = j->next) {
#############		XPUSHs (sv_2mortal (newSVpv (j->data, PL_na)));
#############		g_free (j->data);
#############	}
#############
#############	gnome_vfs_mime_application_list_free (applications);
#############	g_list_free (ids);

# FIXME: Needs bonobo typemaps.
###  gboolean gnome_vfs_mime_id_in_component_list (const char *iid, GList *components) 
#gboolean
#gnome_vfs_mime_id_in_component_list (iid, components)
#	const char *iid
#	GList *components

# FIXME: Needs bonobo typemaps.
###  GList * gnome_vfs_mime_remove_component_from_list (GList *components, const char *iid, gboolean *did_remove) 
#GList *
#gnome_vfs_mime_remove_component_from_list (components, iid, did_remove)
#	GList *components
#	const char *iid
#	gboolean *did_remove

# FIXME: Needs bonobo typemaps.
###  GList * gnome_vfs_mime_id_list_from_component_list (GList *components) 
#GList *
#gnome_vfs_mime_id_list_from_component_list (components)
#	GList *components

# --------------------------------------------------------------------------- #

MODULE = Gnome2::VFS::Mime	PACKAGE = Gnome2::VFS::Mime::Type	PREFIX = gnome_vfs_mime_

SV *
gnome_vfs_mime_new (class, mime_type)
	const char *mime_type
    CODE:
	RETVAL = newSVGnomeVFSMimeType (mime_type);
    OUTPUT:
	RETVAL

##  GnomeVFSMimeActionType gnome_vfs_mime_get_default_action_type (const char *mime_type) 
GnomeVFSMimeActionType
gnome_vfs_mime_get_default_action_type (mime_type)
	GnomeVFSMimeType *mime_type

# FIXME: Needs bonobo typemaps.
###  GnomeVFSMimeAction * gnome_vfs_mime_get_default_action (const char *mime_type) 
#GnomeVFSMimeAction *
#gnome_vfs_mime_get_default_action (mime_type)
#	const char *mime_type

##  GnomeVFSMimeApplication *gnome_vfs_mime_get_default_application (const char *mime_type) 
GnomeVFSMimeApplication *
gnome_vfs_mime_get_default_application (mime_type)
	GnomeVFSMimeType *mime_type

# FIXME: Needs bonobo typemaps.
###  Bonobo_ServerInfo * gnome_vfs_mime_get_default_component (const char *mime_type) 
#Bonobo_ServerInfo *
#gnome_vfs_mime_get_default_component (mime_type)
#	const char *mime_type

##  GList * gnome_vfs_mime_get_short_list_applications (const char *mime_type) 
void
gnome_vfs_mime_get_short_list_applications (mime_type)
	GnomeVFSMimeType *mime_type
    PREINIT:
	GList *i, *applications;
    PPCODE:
	applications = gnome_vfs_mime_get_short_list_applications (mime_type);

	for (i = applications; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGnomeVFSMimeApplication (i->data)));

	g_list_free (applications);

# FIXME: Needs bonobo typemaps.
###  GList * gnome_vfs_mime_get_short_list_components (const char *mime_type) 
#GList *
#gnome_vfs_mime_get_short_list_components (mime_type)
#	const char *mime_type

##  GList * gnome_vfs_mime_get_all_applications (const char *mime_type) 
void
gnome_vfs_mime_get_all_applications (mime_type)
	GnomeVFSMimeType *mime_type
    PREINIT:
	GList *i, *applications;
    PPCODE:
	applications = gnome_vfs_mime_get_all_applications (mime_type);

	for (i = applications; i != NULL; i = i->next)
		XPUSHs (sv_2mortal (newSVGnomeVFSMimeApplication (i->data)));

	g_list_free (applications);

# FIXME: Needs bonobo typemaps.
###  GList * gnome_vfs_mime_get_all_components (const char *mime_type) 
#GList *
#gnome_vfs_mime_get_all_components (mime_type)
#	const char *mime_type

##  GnomeVFSResult gnome_vfs_mime_set_default_action_type (const char *mime_type, GnomeVFSMimeActionType action_type) 
GnomeVFSResult
gnome_vfs_mime_set_default_action_type (mime_type, action_type)
	GnomeVFSMimeType *mime_type
	GnomeVFSMimeActionType action_type

##  GnomeVFSResult gnome_vfs_mime_set_default_application (const char *mime_type, const char *application_id) 
GnomeVFSResult
gnome_vfs_mime_set_default_application (mime_type, application_id)
	GnomeVFSMimeType *mime_type
	const char *application_id

# FIXME: Needs bonobo typemaps.
###  GnomeVFSResult gnome_vfs_mime_set_default_component (const char *mime_type, const char *component_iid) 
#GnomeVFSResult
#gnome_vfs_mime_set_default_component (mime_type, component_iid)
#	const char *mime_type
#	const char *component_iid

##  const char *gnome_vfs_mime_get_icon (const char *mime_type) 
const char *
gnome_vfs_mime_get_icon (mime_type)
	GnomeVFSMimeType *mime_type

##  GnomeVFSResult gnome_vfs_mime_set_icon (const char *mime_type, const char *filename) 
GnomeVFSResult
gnome_vfs_mime_set_icon (mime_type, filename)
	GnomeVFSMimeType *mime_type
	const char *filename

##  GnomeVFSResult gnome_vfs_mime_get_description (const char *mime_type) 
const char *
gnome_vfs_mime_get_description (mime_type)
	GnomeVFSMimeType *mime_type

##  GnomeVFSResult gnome_vfs_mime_set_description (const char *mime_type, const char *description) 
GnomeVFSResult
gnome_vfs_mime_set_description (mime_type, description)
	GnomeVFSMimeType *mime_type
	const char *description

##  gboolean gnome_vfs_mime_can_be_executable (const char *mime_type) 
gboolean
gnome_vfs_mime_can_be_executable (mime_type)
	GnomeVFSMimeType *mime_type

##  GnomeVFSResult gnome_vfs_mime_set_can_be_executable (const char *mime_type, gboolean new_value) 
GnomeVFSResult
gnome_vfs_mime_set_can_be_executable (mime_type, new_value)
	GnomeVFSMimeType *mime_type
	gboolean new_value

##  GnomeVFSResult gnome_vfs_mime_set_short_list_applications (const char *mime_type, GList *application_ids) 
GnomeVFSResult
gnome_vfs_mime_set_short_list_applications (mime_type, first_application_id, ...)
	GnomeVFSMimeType *mime_type
    PREINIT:
	GList *application_ids = NULL;
	int i;
    CODE:
	for (i = 1; i < items; i++)
		application_ids = g_list_append (application_ids, SvPV_nolen (ST (i)));

	RETVAL = gnome_vfs_mime_set_short_list_applications (mime_type, application_ids);

	g_list_free (application_ids);
    OUTPUT:
	RETVAL

# FIXME: Needs bonobo typemaps.
###  GnomeVFSResult gnome_vfs_mime_set_short_list_components (const char *mime_type, GList *component_iids) 
#GnomeVFSResult
#gnome_vfs_mime_set_short_list_components (mime_type, component_iids)
#	const char *mime_type
#	GList *component_iids

##  GnomeVFSResult gnome_vfs_mime_add_application_to_short_list (const char *mime_type, const char *application_id) 
GnomeVFSResult
gnome_vfs_mime_add_application_to_short_list (mime_type, application_id)
	GnomeVFSMimeType *mime_type
	const char *application_id

##  GnomeVFSResult gnome_vfs_mime_remove_application_from_short_list (const char *mime_type, const char *application_id) 
GnomeVFSResult
gnome_vfs_mime_remove_application_from_short_list (mime_type, application_id)
	GnomeVFSMimeType *mime_type
	const char *application_id

# FIXME: Needs bonobo typemaps.
###  GnomeVFSResult gnome_vfs_mime_add_component_to_short_list (const char *mime_type, const char *iid) 
#GnomeVFSResult
#gnome_vfs_mime_add_component_to_short_list (mime_type, iid)
#	const char *mime_type
#	const char *iid

# FIXME: Needs bonobo typemaps.
###  GnomeVFSResult gnome_vfs_mime_remove_component_from_short_list (const char *mime_type, const char *iid) 
#GnomeVFSResult
#gnome_vfs_mime_remove_component_from_short_list (mime_type, iid)
#	const char *mime_type
#	const char *iid

##  GnomeVFSResult gnome_vfs_mime_add_extension (const char *mime_type, const char *extension) 
GnomeVFSResult
gnome_vfs_mime_add_extension (mime_type, extension)
	GnomeVFSMimeType *mime_type
	const char *extension

##  GnomeVFSResult gnome_vfs_mime_remove_extension (const char *mime_type, const char *extension) 
GnomeVFSResult
gnome_vfs_mime_remove_extension (mime_type, extension)
	GnomeVFSMimeType *mime_type
	const char *extension

##  GnomeVFSResult gnome_vfs_mime_extend_all_applications (const char *mime_type, GList *application_ids) 
GnomeVFSResult
gnome_vfs_mime_extend_all_applications (mime_type, first_application_id, ...)
	GnomeVFSMimeType *mime_type
    PREINIT:
	GList *application_ids = NULL;
	int i;
    CODE:
	for (i = 1; i < items; i++)
		application_ids = g_list_append (application_ids, SvPV_nolen (ST (i)));

	RETVAL = gnome_vfs_mime_extend_all_applications (mime_type, application_ids);

	g_list_free (application_ids);
    OUTPUT:
	RETVAL

##  GnomeVFSResult gnome_vfs_mime_remove_from_all_applications (const char *mime_type, GList *application_ids) 
GnomeVFSResult
gnome_vfs_mime_remove_from_all_applications (mime_type, first_application_id, ...)
	GnomeVFSMimeType *mime_type
    PREINIT:
	GList *application_ids = NULL;
	int i;
    CODE:
	for (i = 1; i < items; i++)
		application_ids = g_list_append (application_ids, SvPV_nolen (ST (i)));

	RETVAL = gnome_vfs_mime_remove_from_all_applications (mime_type, application_ids);

	g_list_free (application_ids);
    OUTPUT:
	RETVAL

##  void gnome_vfs_mime_application_list_free (GList *list) 

##  void gnome_vfs_mime_component_list_free (GList *list) 

# --------------------------------------------------------------------------- #

MODULE = Gnome2::VFS::Mime	PACKAGE = Gnome2::VFS::Mime::Application	PREFIX = gnome_vfs_mime_application_

##  GnomeVFSMimeApplication *gnome_vfs_mime_application_new_from_id (const char *id) 
GnomeVFSMimeApplication *
gnome_vfs_mime_application_new_from_id (class, id)
	const char *id
    C_ARGS:
	id

##  GnomeVFSMimeApplication *gnome_vfs_mime_application_copy (GnomeVFSMimeApplication *application) 

##  void gnome_vfs_mime_application_free (GnomeVFSMimeApplication *application) 

#if VFS_CHECK_VERSION (2, 3, 1)

##  GnomeVFSResult gnome_vfs_mime_application_launch (GnomeVFSMimeApplication *app, GList *uris) 
GnomeVFSResult
gnome_vfs_mime_application_launch (app, first_uri, ...)
	GnomeVFSMimeApplication *app
    PREINIT:
	GList *uris = NULL;
	int i;
    CODE:
	for (i = 1; i < items; i++)
		uris = g_list_append (uris, SvPV_nolen (ST (i)));

	RETVAL = gnome_vfs_mime_application_launch (app, uris);

	g_list_free (uris);
    OUTPUT:
	RETVAL
	

###  GnomeVFSResult gnome_vfs_mime_application_launch_with_env (GnomeVFSMimeApplication *app, GList *uris, char **envp) 
#GnomeVFSResult
#gnome_vfs_mime_application_launch_with_env (app, uris, envp)
#	GnomeVFSMimeApplication *app
#	GList *uris
#	char **envp

#endif

# --------------------------------------------------------------------------- #

MODULE = Gnome2::VFS::Mime	PACKAGE = Gnome2::VFS::Mime::Action	PREFIX = gnome_vfs_mime_action_

##  void gnome_vfs_mime_action_free (GnomeVFSMimeAction *action) 

# FIXME: Needs bonobo typemaps.
###  GnomeVFSResult gnome_vfs_mime_action_launch (GnomeVFSMimeAction *action, GList *uris) 
#GnomeVFSResult
#gnome_vfs_mime_action_launch (action, uris)
#	GnomeVFSMimeAction *action
#	GList *uris

###  GnomeVFSResult gnome_vfs_mime_action_launch_with_env (GnomeVFSMimeAction *action, GList *uris, char **envp) 
#GnomeVFSResult
#gnome_vfs_mime_action_launch_with_env (action, uris, envp)
#	GnomeVFSMimeAction *action
#	GList *uris
#	char **envp

# --------------------------------------------------------------------------- #

MODULE = Gnome2::VFS::Mime	PACKAGE = Gnome2::VFS::Mime::Monitor	PREFIX = gnome_vfs_mime_monitor_
 
##  GnomeVFSMIMEMonitor *gnome_vfs_mime_monitor_get (void)
GnomeVFSMIMEMonitor *
gnome_vfs_mime_monitor_get (class)
    C_ARGS:
	/* void */
