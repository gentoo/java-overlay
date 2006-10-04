# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/java-gnome/java-gnome-2.10.1.ebuild,v 1.3 2005/07/10 18:52:54 agriffis Exp $

inherit eutils

DESCRIPTION="A meta package for all the bindings libraries necessary to write GNOME/GTK applicatons in Java"
HOMEPAGE="http://java-gnome.sourceforge.net/"
DEPEND="!<dev-java/java-gnome-2.8
	>=dev-java/libgtk-java-2.6.2
	>=dev-java/libgnome-java-2.10.1
	>=dev-java/libgconf-java-2.10.1
	>=dev-java/libglade-java-2.10.1
	doc? ( >=virtual/jdk-1.2 )"

SLOT="2.10"
LICENSE="as-is"
KEYWORDS="~ppc ~x86"
IUSE="doc"

pkg_setup() {

	einfo ""
	einfo "At the 2.8 release, the java-gnome project made considerably changes to"
	einfo "its structure. Instead of one monolithic java-gnome package, there are"
	einfo "now indiviudal builds for libgtk-java, libgnome-java, libglade-java, etc"
	einfo ""
	einfo "The java-gnome ebuild is now a meta package which simply depends on"
	einfo "the various new ebuilds, to make it easy to pull them all in."
	einfo ""
	ewarn "While this ebuild is slotted 2.10, it is marked as being blocked by"
	ewarn "the presence of older versions of java-gnome if they exist on your"
	ewarn "system. Not only were the 2.6 bindings really buggy, but with the"
	ewarn "major re-organization of this package into modular pieces, the"
	ewarn "risk of library and/or jar naming collisions was deemed too high."
	einfo ""
	einfo "java-gnome 2.8 and 2.10 can co-exist on your system, but you really"
	einfo "only need the older gtk 2.4 / gnome 2.8 series (instead of the"
	einfo "current gtk 2.6 / gnome 2.10 series) if you don't have GNOME 2.10 yet."
	einfo ""
}

src_compile() {

	#
	# Upstream's reorg led to a total mess with the generated Javadoc. 
	# We need to address it, but now the automake is building all the
	# javadoc more or less like-it-or-not, so we'll need to act there.
	#
	return
}

src_install() {
	einfo "creating symlinks for convenience and backwards compatability"

	#
	# This is just here for convenience and for legacy compatability.
	#
	# This isn't meant to be Java policy compliant. There is no
	# package.env file for this ebuild because the individual libraries
	# it depends on all have proper package.env (which this uses, in fact).
	#

	mkdir -p ${D}/usr/share/java-gnome/lib
	cd ${D}/usr/share/java-gnome/lib

	gtk_jar=`java-config -p libgtk-java-2.6`
	ln -s $gtk_jar `basename $gtk_jar`

	gnome_jar=`java-config -p libgnome-java-2.10`
	ln -s $gnome_jar `basename $gnome_jar`

	glade_jar=`java-config -p libglade-java-2.10`
	ln -s $glade_jar `basename $glade_jar`

	gconf_jar=`java-config -p libgconf-java-2.10`
	ln -s $gconf_jar `basename $gconf_jar`


	use doc || return
}

