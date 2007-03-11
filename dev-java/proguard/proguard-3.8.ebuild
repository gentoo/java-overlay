# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/proguard/proguard-3.6.ebuild,v 1.5 2007/02/03 04:59:04 beandog Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Free Java class file shrinker, optimizer, and obfuscator."
HOMEPAGE="http://proguard.sourceforge.net/"
SRC_URI="mirror://sourceforge/proguard/${PN}${PV}.tar.gz"

LICENSE="GPL-2-with-linking-exception"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples"

DEPEND=">=virtual/jdk-1.4
	dev-java/sun-j2me-bin
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}/${PN}${PV}

# TODO: proguardgui does not start

src_unpack() {
	unpack ${A}
	cp ${FILESDIR}/build.xml "${S}"
	rm ${S}/lib/*.jar
	cd "${S}" && java-ant_rewrite-classpath
}

src_compile() {
	eant -Dgentoo.classpath=$(java-pkg_getjars sun-j2me-bin,ant-core) proguard
}

src_install() {
	cd "${S}"
	java-pkg_dojar dist/*
	java-pkg_dolauncher ${PN} --main proguard.ProGuard
	java-pkg_dolauncher ${PN}gui --main proguard.gui.ProGuardGUI
	java-pkg_dolauncher ${PN}_retrace --main proguard.retrace.ReTrace

	if use doc; then
		java-pkg_dojavadoc docs
	fi

	if use examples; then
		java-pkg_dohtml -r examples
	fi
}

pkg_postinst() {

	elog "Please see http://proguard.sourceforge.net/GPL_exception.html"
	elog "for linking exception information about ${PN}"

}
