#!/usr/bin/perl -w
use 5.008;
use strict;
use ExtUtils::MakeMaker;
use Cwd;
use File::Spec;

# $Header: /cvsroot/gtk2-perl/gtk2-perl-xs/Gnome2-VFS/Makefile.PL,v 1.9 2003/11/24 23:18:54 kaffeetisch Exp $

our %build_reqs = (
	'perl-ExtUtils-Depends'   => '0.1',
	'perl-ExtUtils-PkgConfig' => '0.1',
	'perl-Glib'               => '1.01',
	'GnomeVFS'                => '2.0.0',
);

unless (eval "use ExtUtils::Depends;"
           . "use ExtUtils::PkgConfig;"
           . "use Glib '$build_reqs{'perl-Glib'}';"
           . "use Glib::MakeHelper;"
	   . "use Gtk2::CodeGen;"
           . "1") {
   warn "$@\n";
   WriteMakefile(
         PREREQ_FATAL => 1,
         PREREQ_PM    => {
            "Gtk2"                => $build_reqs{'perl-Gtk2'},
            "Glib"                => $build_reqs{'perl-Glib'},
            "ExtUtils::Depends"   => $build_reqs{'perl-ExtUtils-Depends'},
            "ExtUtils::PkgConfig" => $build_reqs{'perl-ExtUtils-PkgConfig'},
         },
   );
   exit 1; # not reached
}

my %vfs_pkgcfg = ExtUtils::PkgConfig->find("gnome-vfs-2.0 >= $build_reqs{GnomeVFS}");

my %cfgs = (
	vfs => \%vfs_pkgcfg,
);

###############################################################################

mkdir 'build', 0777;

chomp(my $vfs_includes = `pkg-config --variable includedir gnome-vfs-2.0`);
my @vfs_headers = glob($vfs_includes . "/gnome-vfs-2.0/libgnomevfs/*.h");

system(q(glib-mkenums --fhead "#ifndef __VFS2PERL_GTYPES_H__\n" ) .
                    q(--fhead "#define __VFS2PERL_GTYPES_H__ 1\n\n" ) .
                    q(--fhead "#include <glib-object.h>\n\n" ) .
                    q(--fhead "G_BEGIN_DECLS\n\n" ) .
                    q(--eprod "#define VFS2PERL_GNOME_TYPE_@ENUMSHORT@ vfs2perl_@enum_name@_get_type()\n" ) .
                    q(--eprod "GType vfs2perl_@enum_name@_get_type (void);\n" ) .
                    q(--ftail "G_END_DECLS\n\n" ) .
                    q(--ftail "#endif /* __VFS2PERL_GTYPES_H__ */\n" ) .
                    "@vfs_headers > build/vfs2perl-gtypes.h");

system(q(glib-mkenums --fhead "#include <libgnomevfs/gnome-vfs-types.h>\n" ) .
                    q(--fhead "#include <libgnomevfs/gnome-vfs-utils.h>\n" ) .
                    q(--fhead "#include <libgnomevfs/gnome-vfs-monitor.h>\n" ) .
                    q(--fhead "#include <libgnomevfs/gnome-vfs-mime-handlers.h>\n" ) .
                    q(--fhead "#include <libgnomevfs/gnome-vfs-directory.h>\n" ) .
                    q(--vhead "static const G@Type@Value _vfs2perl_@enum_name@_values[] = {" ) .
                    q(--vprod "  { @VALUENAME@, \"@VALUENAME@\", \"@valuenick@\" }," ) .
                    q(--vtail "  { 0, NULL, NULL }\n};\n\n" ) .
                    q(--vtail "GType\nvfs2perl_@enum_name@_get_type (void)\n{\n" ) .
                    q(--vtail "  static GType type = 0;\n\n" ) .
                    q(--vtail "  if (!type)\n" ) .
                    q(--vtail "    type = g_@type@_register_static (\"@EnumName@\", _vfs2perl_@enum_name@_values);\n\n" ) .
                    q(--vtail "  return type;\n}\n\n" ) .
                    "@vfs_headers > build/vfs2perl-gtypes.c");

# UGLY, UGLY, UGLY!
system("perl -pi -e 's/VFS2PERL_GNOME_TYPE_VFSURI_HIDE_OPTIONS/VFS2PERL_GNOME_TYPE_VFS_URI_HIDE_OPTIONS/g;
                     s/vfs2perl_gnome_vfsuri_hide_options/vfs2perl_gnome_vfs_uri_hide_options/g' build/vfs2perl-gtypes.h build/vfs2perl-gtypes.c");

###############################################################################

our @xs_files = <xs/*.xs>;
our %pod_files = (
	'VFS.pm' => '$(INST_MAN3DIR)/Gnome2::VFS.$(MAN3EXT)',
	Glib::MakeHelper->do_pod_files (@xs_files),
);

Glib::MakeHelper->do_pod_files (@xs_files);

Gtk2::CodeGen->parse_maps ('vfs2perl');
Gtk2::CodeGen->write_boot (ignore => qr/^Gnome2::VFS$/);

open VERSION, ">build/vfs2perl-version.h" or die("Opening '>build/vfs2perl-version.h': $!");
foreach my $pkg (keys %cfgs) {
	my $stem = uc $pkg;
	my @modversion = split /\./, $cfgs{$pkg}{modversion};
	print VERSION "#define $stem\_MAJOR_VERSION   ($modversion[0])\n";
	print VERSION "#define $stem\_MINOR_VERSION   ($modversion[1])\n";
	print VERSION "#define $stem\_MICRO_VERSION   ($modversion[2])\n";
	print VERSION
	     "#define $stem\_CHECK_VERSION(major,minor,micro) \\\n"
	   . "    ($stem\_MAJOR_VERSION > (major) || \\\n"
	   . "     ($stem\_MAJOR_VERSION == (major) && $stem\_MINOR_VERSION > (minor)) || \\\n"
	   . "     ($stem\_MAJOR_VERSION == (major) && $stem\_MINOR_VERSION == (minor) && \\\n"
	   . "      $stem\_MICRO_VERSION >= (micro)))\n";
}
close VERSION;

###############################################################################

my $vfs = ExtUtils::Depends->new ('Gnome2::VFS', 'Gtk2', 'Glib');
$vfs->set_inc ($vfs_pkgcfg{cflags});
$vfs->set_libs ($vfs_pkgcfg{libs});
$vfs->add_xs (@xs_files);
$vfs->add_c ("vfs2perl.c", "build/vfs2perl-gtypes.c");
$vfs->add_pm ('VFS.pm' => '$(INST_LIBDIR)/VFS.pm');
$vfs->add_typemaps (map {File::Spec->catfile(cwd(), $_)} 'build/vfs2perl.typemap', 'vfs.typemap');
$vfs->add_headers ('vfs2perl.h');

$vfs->install (qw(vfs2perl.h
                  build/vfs2perl-autogen.h
                  build/vfs2perl-version.h
                  build/vfs2perl-gtypes.h));
$vfs->save_config ('build/IFiles.pm');

WriteMakefile(
    NAME            => 'Gnome2::VFS',
    VERSION_FROM    => 'VFS.pm', # finds $VERSION
    ABSTRACT_FROM   => 'VFS.pm', # retrieve abstract from module
    XSPROTOARG      => '-noprototypes',
    MAN3PODS        => \%pod_files,
    $vfs->get_makefile_vars,
);

###############################################################################

package MY;

sub postamble
{
	return Glib::MakeHelper->postamble_clean ()
	     . Glib::MakeHelper->postamble_docs (@main::xs_files);
}

package MAIN;
