# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils flag-o-matic java-pkg-2 base

DESCRIPTION="Java bindings for the D-Bus messagebus."
HOMEPAGE="http://dbus.freedesktop.org/"
SRC_URI="http://dbus.freedesktop.org/releases/dbus-java/${P}.tar.gz"

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc source"

RDEPEND=">=virtual/jre-1.5
	 >=sys-apps/dbus-1.0"

DEPEND=">=virtual/jdk-1.5
	>=sys-apps/dbus-1.0
	doc? ( app-text/docbook2X dev-tex/tex4ht )
	source? ( app-arch/zip )"

PATCHES="${FILESDIR}/1.12-load-library.patch"

src_compile() {
	append-flags -DDBUS_API_SUBJECT_TO_CHANGE=1
	emake -j1 LDFLAGS="$(raw-ldflags)" JCFLAGS="$(java-pkg_javac-args)"
	if use doc; then
		for i in `ls *.sgml`; do
			docbook2man $i || die;
			mv DBUS-JAVA.1 $(echo $i | sed 's/sgml/1/g') || die;
		done
		emake doc
	fi
}

src_install() {
	java-pkg_newjar ${P}.jar dbus.jar
	java-pkg_newjar dbus-java-viewer-${PV}.jar dbus-java-viewer.jar
	java-pkg_doso ${PN}.so

	java-pkg_dolauncher CreateInterface --jar dbus.jar \
		--main org.freedesktop.dbus.CreateInterface

	java-pkg_dolauncher DBusViewer \
		--main org.freedesktop.dbus.viewer.DBusViewer

	java-pkg_dolauncher ListDBus --jar dbus.jar \
		--main org.freedesktop.dbus.ListDBus
	doman *.1
	dodoc COPYING INSTALL changelog AUTHORS README || die
	use source && java-pkg_dosrc org/
	use doc && java-pkg_dojavadoc doc/api
	use doc && java-pkg_dohtml doc/dbus-java/*
}
