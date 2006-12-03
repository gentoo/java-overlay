# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/xalan/xalan-2.7.0-r2.ebuild,v 1.5 2006/09/14 00:29:07 nichoj Exp $

inherit java-pkg-2 java-ant-2 eutils versionator

MY_PN="xalan-j"
MY_PV="$(replace_all_version_separators _)"
MY_P="${MY_PN}_${MY_PV}"
DESCRIPTION="DOM Level 3 serializer from Apache Xalan, shared by Xalan and Xerces"
HOMEPAGE="http://xml.apache.org/xalan-j/index.html"
SRC_URI="mirror://apache/xml/${MY_PN}/source/${MY_P}-src.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86"
IUSE="doc source"
COMMON_DEP="=dev-java/xml-commons-external-1.3*"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.5.2
	source? ( app-arch/zip )
	${COMMON_DEP}"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# kill all non-serializer sources to ease javadocs and dosrc
	cd src/org/apache
	mv xml/serializer "${T}/" || die "failed to mv to temp"
	rm -rf ./*
	mkdir xml
	mv "${T}/serializer" xml/ || die "failed to mv from temp"

	# kill bundled jars and packed xml-commons-external sources
	cd "${S}"
	rm -f lib/*.jar tools/*.jar src/*.tar.gz

	cd lib
	java-pkg_jar-from xml-commons-external-1.3 xml-apis.jar
}

src_compile() {
	eant serializer.jar $(use_doc serializer.javadocs)
}

src_install() {
	java-pkg_dojar build/serializer.jar
	use doc && java-pkg_dojavadoc build/docs/apidocs
	use source && java-pkg_dosrc src/org
}
