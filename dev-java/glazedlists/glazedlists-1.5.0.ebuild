# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/glazedlists/glazedlists-0.9.6.ebuild,v 1.6 2005/10/07 21:08:40 betelgeuse Exp $

# java-ant-2 not needed - build.xml sets source/target properly
inherit java-pkg-2 eutils

DESCRIPTION="A toolkit for list transformations"
HOMEPAGE="http://publicobject.com/glazedlists/"
SRC_URI="https://${PN}.dev.java.net/files/documents/1073/26115/${P}-source_java14.zip"
LICENSE="LGPL-2.1"
SLOT="1.5"
KEYWORDS="~x86"
IUSE="doc source test"
RESTRICT="nomirror"
RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	test? ( dev-java/junit )
	app-arch/unzip"
S=${WORKDIR}

# looks like tests are not 1.4 ready (expect autoboxing)
RESTRICT="test"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# disable autodownloading and make swt extension optional (TODO useflag?)
	# sort out test targets
	epatch "${FILESDIR}/${P}-build.xml.patch"

	if use test; then
		cd extensions
		java-pkg_jar-from junit junit.jar
	fi
}

src_compile() {
	eant jar $(use_doc docs)
}

src_test() {
	eant test
}

src_install() {
	java-pkg_newjar "${PN}_java14.jar" "${PN}.jar"
	if use doc; then
		dohtml readme.html
		java-pkg_dohtml -r docs/api
	fi
	use source && java-pkg_dosrc "source/ca"
}
