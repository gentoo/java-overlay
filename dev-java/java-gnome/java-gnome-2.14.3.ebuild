# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/java-gnome/java-gnome-2.10.1.ebuild,v 1.3 2005/07/10 18:52:54 agriffis Exp $

inherit eutils

DESCRIPTION="A meta package for all the bindings libraries necessary to write GNOME/GTK applicatons in Java"
HOMEPAGE="http://java-gnome.sourceforge.net/"
DEPEND="!<dev-java/java-gnome-2.8
	~dev-java/glib-java-0.2.6
	~dev-java/cairo-java-1.0.5
	~dev-java/libgtk-java-2.8.7
	~dev-java/libgnome-java-2.12.5
	~dev-java/libglade-java-2.12.6
	~dev-java/libgconf-java-2.12.4
	~dev-java/libvte-java-0.12.1"
# Should also have libeds-java, but doesn't quite work yet.

SLOT="2.12"
LICENSE="as-is"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

pkg_setup() {

	einfo ""
	einfo "At the 2.8 release, the java-gnome project made considerably changes to"
	einfo "its structure. Instead of one monolithic java-gnome package, there were"
	einfo "now indiviudal builds for libgtk-java, libgnome-java, libglade-java,"
	einfo "and libgconf-java"
	einfo ""
	einfo "At the 2.12 release, the java-gnome project added a base library, called"
	einfo "glib-java which contains the core memory management code. In due course,"
	einfo "other org.gnu.glib classes may migrate there from libgtk-java, but it"
	einfo "doesn't really matter. Note that you need glib0.2.jar on your classpath"
	einfo "in addition to gtk2.8.jar now."
	einfo "You may or may not find yourself needing something called cairo1.0.jar"
	einfo "on your classpath - it's the Java bindings around the Cairo graphics"
	einfo "library, also new as of GTK+ 2.8 / GNOME 2.12. cairo-java is a"
	einfo "dependency of libgtk-java so you'll see that come in"
	einfo ""
	einfo "The java-gnome ebuild remeains a meta package which simply depends on"
	einfo "the various ebuilds which make up the java-gnome family, to make it easy"
	einfo "to pull them all in."
	einfo ""
	einfo "java-gnome 2.8, 2.10 and 2.12 can co-exist on your system, but you really"
	einfo "only need the older gtk 2.6 / gnome 2.10 series (instead of the"
	einfo "current gtk 2.8 / gnome 2.12 series) if you don't have GNOME 2.12 yet."
	einfo "You can emerge libglade-java USE=-gnome to avoid the GNOME dependencies."
	einfo "Note that there is zero bugfix activity going on in the 2.8 or 2.10"
	einfo "series upstream."
}

src_compile() {

	#
	# Upstream's reorg led to a total mess with the generated Javadoc. 
	# We need to address it, but now the automake is building all the
	# javadoc more or less like-it-or-not, so we'll need to act there.
	#
	return
}
