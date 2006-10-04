# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/java-gnome/java-gnome-2.8.3.ebuild,v 1.2 2005/06/29 15:11:51 axxo Exp $

inherit eutils

DESCRIPTION="A meta package for all the bindings libraries necessary to write GNOME/GTK applicatons in Java"
HOMEPAGE="http://java-gnome.sourceforge.net/"
DEPEND="!<dev-java/java-gnome-2.8
	>=dev-java/libgtk-java-2.4.8.1
	>=dev-java/libgnome-java-2.8.3.1
	>=dev-java/libgconf-java-2.8.3.1
	>=dev-java/libglade-java-2.8.3.1
	doc? ( >=virtual/jdk-1.2 )"

SLOT="2.8"
LICENSE="as-is"
KEYWORDS="~amd64 ~ppc x86"
IUSE="doc"

pkg_setup() {

	einfo ""
	einfo "The java-gnome project has made considerably changes to its internal"
	einfo "structure. Instead of one monolithic java-gnome package, there are"
	einfo "now indiviudal builds for libgtk-java, libgnome-java, libglade-java, etc"
	einfo ""
	einfo "This java-gnome ebuild is now a meta package which simply depends on"
	einfo "the various new ebuilds"
	einfo ""
	ewarn "While this ebuild is slotted 2.8, it is marked as being blocked by"
	ewarn "the presence of older versions of java-gnome if they exist on your"
	ewarn "system. Not only were the 2.6 bindings really buggy, but with the"
	ewarn "major re-organization of this package into modular pieces, the"
	ewarn "risk of library and/or jar naming collisions is too high."
	einfo ""
	einfo "By the time you see this message, the above issues have been"
	einfo "resolved (ie the new lib*-java packages will all be merged,"
	einfo "and any old java-gnome packages are now removed)."
	einfo ""
}

src_compile() {
	use doc || return

	#
	# Upstream's reorg led to a total mess with the generated Javadoc. 
	# This attempts to replace it for the time being, creating Javadoc
	# for all the java-gnome libraries at one go (which makes way more sense
	# than one per library scattered all over)
	#

	cd ${WORKDIR}

	# Yes, this is terrible hard coding. I'd welcome someone telling me
	# how to do this better.

	unzip -o -q /usr/share/libgtk-java-2.4/src/libgtk-java-2.4.8.1.src.zip -d java
	unzip -o -q /usr/share/libgnome-java-2.8/src/libgnome-java-2.8.3.1.src.zip -d java
	unzip -o -q /usr/share/libgconf-java-2.8/src/libgconf-java-2.8.3.1.src.zip -d java
	unzip -o -q /usr/share/libglade-java-2.8/src/libglade-java-2.8.3.1.src.zip -d java

	javadoc \
		-public -use -version -author \
		-windowtitle "java-gnome ${PV} API Reference" \
		-doctitle "API reference for <B><TT>java-gnome</TT></B>, version ${PV}" \
		-d api \
		-sourcepath java \
			org.gnu.glib \
			org.gnu.pango \
			org.gnu.atk \
			org.gnu.gdk \
			org.gnu.gtk \
			org.gnu.gtk.event \
			org.gnu.gnome \
			org.gnu.gnome.event \
			org.gnu.glade \
			org.gnu.gconf
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

	gtk_jar=`java-config -p libgtk-java-2.4`
	ln -s $gtk_jar `basename $gtk_jar`

	gnome_jar=`java-config -p libgnome-java-2.8`
	ln -s $gnome_jar `basename $gnome_jar`

	glade_jar=`java-config -p libglade-java-2.8`
	ln -s $glade_jar `basename $glade_jar`

	gconf_jar=`java-config -p libgconf-java-2.8`
	ln -s $gconf_jar `basename $gconf_jar`


	use doc || return

	mkdir -p ${D}/usr/share/doc/${PF}
	mv ${WORKDIR}/api ${D}/usr/share/doc/${PF}
}

