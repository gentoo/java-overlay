# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: Joshua Nichols <nichoj@gentoo.org>
# Purpose:  Reduce repeated code betwen the java-gnome packages
#

# Must be before the gnome.org inherit
GNOME_TARBALL_SUFFIX=${GNOME_TARBALL_SUFFIX:=gz}
inherit java-pkg-2 eutils gnome.org


ECLASS="java-gnome"
INHERITED="$INHERITED $ECLASS"

HOMEPAGE="http://java-gnome.sourceforge.net/"
LICENSE="LGPL-2.1"

IUSE="gcj doc source"
RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
	source? ( app-arch/zip )
	dev-util/pkgconfig"

if [[ -z ${JAVA_GNOME_BINDINGS} ]]; then 
	JAVA_GNOME_BINDINGS=${PN}
	JAVA_GNOME_BINDINGS=${JAVA_GNOME_BINDINGS/-java/}
	# skip over glib because it's too good for our heuristic
	[[ ${JAVA_GNOME_BINDINGS} != "glib" ]] && 
		JAVA_GNOME_BINDINGS=${JAVA_GNOME_BINDINGS/lib/}
fi

JAVA_GNOME_JARNAME="${JAVA_GNOME_BINDINGS}${SLOT}.jar"
JAVA_GNOME_JARPATH="${JAVA_PKG_JARDEST}/${JARNAME}"

JAVA_GNOME_PC=${JAVA_GNOME_PC:="${JAVA_GNOME_BINDINGS}-java.pc"}

# Override arguments to econf, by calling java-gnome_src_compile
# with the extra args

java-gnome_pkg_setup() {
	java-pkg-2_pkg_setup
	use gcj && java-pkg_ensure-gcj
}

java-gnome_src_compile() {
	JNI_INCLUDES=$(java-pkg_get-jni-cflags) \
	JAVAC="javac $(java-pkg_javac-args)" econf \
		$(use_with doc javadocs) \
		$(use_with gcj gcj-compile) \
		--with-jardir=${JAVA_PKG_JARDEST} \
		"$@" || die "configure failed"

	emake || die "compile failed"

	# Fix the broken pkgconfig file
	sed -i \
		-e "s:classpath.*$:classpath=\${prefix}/share/${PN}-${SLOT}/lib/${JAVA_GNOME_JARNAME}:" \
		${S}/${JAVA_GNOME_PC} || die "sed failed"
}

java-gnome_src_install() {
	emake DESTDIR=${D} install || die "install failed"

	java-pkg_regjar ${JAVA_GNOME_JARPATH}
	# Examples as documentation
	use doc || rm -rf ${D}/usr/share/doc/${PF}/examples

	use source && java-pkg_dosrc ${S}/src/java/*
}

EXPORT_FUNCTIONS pkg_setup src_compile src_install
