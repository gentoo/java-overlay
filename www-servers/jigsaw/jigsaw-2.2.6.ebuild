# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="1"
JAVA_PKG_IUSE="doc source"
inherit java-pkg-2 java-ant-2

DESCRIPTION="A Java-based web server from W3C"
HOMEPAGE="http://www.w3.org/Jigsaw"
SRC_URI="http://jigsaw.w3.org/Distrib/${PN}_${PV}.tar.bz2"
LICENSE="W3C"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="dev-java/jakarta-oro:2.0
	dev-java/saxon:6.5
	dev-java/servletapi:2.3
	dev-java/xerces:2
	dev-java/jtidy
	dev-java/xp"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.4"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.4"

S="${WORKDIR}/Jigsaw"

JAVA_ANT_REWRITE_CLASSPATH="true"
EANT_DOC_TARGET="javadocs"
EANT_GENTOO_CLASSPATH="jakarta-oro-2.0 saxon-6.5 servletapi-2.3 xerces-2 jtidy xp"
EANT_NEEDS_TOOLS="true"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Delete bundled JARs.
	rm -vf classes/*.jar || die

	# Use generated javadocs instead.
	rm -rf Jigsaw/WWW/Doc/Programmer/api || die

	# Replace useless default with an almost-as-useless default.
	sed -i "s:/0/w3c/ylafon/Distrib/Jigsaw/Jigsaw:.:g" Jigsaw/config/*.props || die
}

src_install() {
	java-pkg_dojar classes/jig*.jar
	dodoc ANNOUNCE README || die

	java-pkg_dolauncher jigsaw --main org.w3c.jigsaw.Main
	java-pkg_dolauncher jigkill --main org.w3c.jigsaw.admin.JigKill
	java-pkg_dolauncher jigadmin --main org.w3c.jigadmin.Main
	java-pkg_dolauncher jigadm --main org.w3c.jigadm.Main

	insinto "/usr/share/${PN}/server"
	doins -r Jigsaw/{config,configadm,logs,trash,WWW} || die
	dosym /usr/share/doc/${PF}/html/api "${INSDESTTREE}/WWW/Doc/Programmer/api"

	use doc && java-pkg_dojavadoc ant.build/javadocs
	use source && java-pkg_dosrc src/classes/*
}

pkg_postinst() {
	einfo "Files needed by the server have been installed to /usr/share/${PN}/server."
	einfo "You should copy these to a writeable location and pass this location as the"
	einfo "-root argument when launching the server."
}
