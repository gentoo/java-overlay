# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2

DESCRIPTION="Java bindings for the D-Bus messagebus."
HOMEPAGE="http://dbus.freedesktop.org/"
SRC_URI="http://dbus.freedesktop.org/releases/dbus-java/${P}.tar.gz"

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug doc source"

RDEPEND=">=virtual/jre-1.5"

DEPEND=">=virtual/jdk-1.5
	app-text/docbook-sgml-utils
	!dev-java/libdbus-java
	dev-java/libmatthew-java
	doc? ( dev-tex/tex4ht )
	source? ( app-arch/zip )"

src_compile() {
	local debug="disable"
	use debug && debug="enable"
	local libdir=$(java-pkg_getjar libmatthew-java unix.jar)
	libdir=${libdir/unix.jar/}
	emake -j1 JCFLAGS="$(java-pkg_javac-args)" \
		STRIP=echo DEBUG=${debug} JAVAUNIXJARDIR=${libdir}

	for i in *.sgml; do
		docbook2man $i || die;
		mv DBUS-JAVA.1 $(echo $i | sed 's/sgml/1/g') || die;
	done
	
	for jar in unix debug-${debug} hexdump; do
		java-pkg_getjar libmatthew-java ${jar}.jar > /dev/null
	done

	use doc && emake doc
}

src_install() {
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
	dodoc COPYING INSTALL changelog AUTHORS README || die
	use source && java-pkg_dosrc org/
	use doc && java-pkg_dojavadoc doc/api
	use doc && java-pkg_dohtml doc/dbus-java/*
}
