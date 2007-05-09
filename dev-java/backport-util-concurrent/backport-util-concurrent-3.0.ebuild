# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/backport-util-concurrent/backport-util-concurrent-1.1.01-r1.ebuild,v 1.2 2006/07/22 21:44:22 nelchael Exp $

JAVA_PKG_IUSE="doc java5 source test"
inherit java-pkg-2 java-ant-2

DESCRIPTION="This package is the backport of java.util.concurrent API, introduced in Java 5.0, to Java 1.4, and from Java 6.0 to Java 5.0"
HOMEPAGE="http://www.mathcs.emory.edu/dcl/util/backport-util-concurrent/"
SRC_URI="!java5? ( http://dcl.mathcs.emory.edu/util/${PN}/dist/${P}/Java14/${P}-src.zip )
	java5? ( http://dcl.mathcs.emory.edu/util/${PN}/dist/${P}/Java50/${PN}-Java50-${PV}-src.zip )"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

DEPEND="java5? ( =virtual/jdk-1.5* )
	!java5? ( =virtual/jdk-1.4* )
	test? ( =dev-java/junit-3* )"
RDEPEND="java5? ( >=virtual/jdk-1.5 )
	!java5? ( >=virtual/jre-1.4 )"

S="${WORKDIR}/${P}-src"

src_unpack() {
	unpack ${A}
	# This is just workaround because setting ${S} in pkg_setup doesn't currently
	# work and this seems better than doing it in global scope
	if use java5; then
		mv ${PN}-Java50-${PV}-src ${P}-src || die
	fi
	cd "${S}"

	if use test; then
		# make test not dependo n make
		epatch "${FILESDIR}/${P}-test.patch"
	else
		# don't compile test classes
		epatch "${FILESDIR}/${P}-notest.patch"
	fi

	cd "${S}/external"
	rm -v *.jar || die

	use test && java-pkg_jar-from --build-only junit
}

EANT_BUILD_TARGET="javacompile archive"

src_test() {
	eant test
}

src_install() {
	java-pkg_dojar ${PN}.jar
	dohtml README.html || die

	use doc && java-pkg_dojavadoc doc/api
	use source && java-pkg_dosrc src/*
}
