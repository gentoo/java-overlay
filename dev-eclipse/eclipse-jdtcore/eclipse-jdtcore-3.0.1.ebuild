# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/jasperreports/jasperreports-0.6.1-r2.ebuild,v 1.3 2005/01/20 16:02:31 mr_bones_ Exp $

inherit java-pkg

MY_A=${P}-src
DESCRIPTION="Eclipse Java Development Tools"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://scott.progbits.com/${MY_A}.tar.bz2"
LICENSE="CPL-1.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="doc"
DEPEND=">=virtual/jdk-1.4
	>=app-arch/unzip-5.50
	>=dev-java/ant-core-1.4
	=dev-eclipse/eclipse-osgi-${PV}
	=dev-eclipse/eclipse-runtime-${PV}"
RDEPEND=">=virtual/jre-1.4"

src_unpack() {
	unpack ${A}

	cd ${WORKDIR}/${MY_A}
	java-pkg_jar-from ant-tasks
	java-pkg_jar-from ant-core
	java-pkg_jar-from eclipse-osgi-3.0
	java-pkg_jar-from eclipse-runtime-3.0
}

src_compile() {
	cd ${WORKDIR}/${MY_A}
	local antflags="jdtcore.jar"

	antflags="${antflags} -lib ./"
	antflags="${antflags} -DjavacFailOnError=true"

	ant ${antflags} || die "Compilation failed"
}

src_install() {
	cd ${WORKDIR}/${MY_A}
	java-pkg_dojar *.jar || die "Missing jars"
}
