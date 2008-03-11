# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"
inherit eutils java-pkg-2

DESCRIPTION="Java bindings for the D-Bus messagebus."
HOMEPAGE="http://dbus.freedesktop.org/"
SRC_URI="http://dbus.freedesktop.org/releases/dbus-java/${P}.tar.gz"

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug"

RDEPEND=">=virtual/jre-1.5
	>=dev-java/libmatthew-java-0.6"

DEPEND=">=virtual/jdk-1.5
	app-text/docbook-sgml-utils
	dev-java/libmatthew-java
	sys-devel/gettext
	doc? ( dev-tex/tex4ht )"

src_unpack() {
	unpack ${A}
	cd "${S}" || die
	epatch "${FILESDIR}"/"${P}"-jarfixes.patch
}

src_compile() {
	local debug="disable"
	use debug && debug="enable"
	local libdir=$(dirname $(java-pkg_getjar libmatthew-java unix.jar))
	emake -j1 JCFLAGS="$(java-pkg_javac-args)" \
		STRIP=echo DEBUG=${debug} JAVAUNIXJARDIR=${libdir}

	for i in *.sgml; do
		docbook2man $i || die;
		mv DBUS-JAVA.1 $(echo $i | sed 's/sgml/1/g') || die;
	done

	use doc && emake doc
}

src_install() {
	local debug="disable"
	use debug && debug="enable"
	for jar in unix debug-${debug} hexdump; do
		java-pkg_register-dependency libmatthew-java ${jar}.jar
	done
	java-pkg_newjar lib${P}.jar dbus.jar
	java-pkg_newjar dbus-java-viewer-${PV}.jar dbus-java-viewer.jar
	java-pkg_newjar dbus-java-bin-${PV}.jar dbus-java-bin.jar
	local javaargs='-DPid=$$'
	javaargs="${javaargs} -DVersion=${PV}"

	java-pkg_dolauncher CreateInterface --jar dbus-java-bin.jar \
		--main org.freedesktop.dbus.bin.CreateInterface \
		--java_args ${javaargs}

	java-pkg_dolauncher DBusViewer --jar dbus-java-viewer.jar \
		--main org.freedesktop.dbus.viewer.DBusViewer \
		--java_args ${javaargs}

	java-pkg_dolauncher ListDBus --jar dbus-java-bin.jar \
		--main org.freedesktop.dbus.bin.ListDBus \
		--java_args ${javaargs}

	java-pkg_dolauncher DBusDaemon --jar dbus-java-bin.jar \
		--main org.freedesktop.dbus.bin.DBusDaemon \
		--java_args ${javaargs}
	java-pkg_dolauncher DBusCall --jar dbus-java-bin.jar \
		--main org.freedesktop.dbus.bin.Caller \
		--java_args ${javaargs}

	doman *.1
	dodoc INSTALL changelog AUTHORS README || die
	use source && java-pkg_dosrc org/
	use doc && java-pkg_dojavadoc doc/api
	use doc && java-pkg_dohtml doc/dbus-java/*
}
