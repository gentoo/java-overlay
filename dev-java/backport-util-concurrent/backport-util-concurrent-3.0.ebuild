# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/backport-util-concurrent/backport-util-concurrent-1.1.01-r1.ebuild,v 1.2 2006/07/22 21:44:22 nelchael Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="This package is the backport of java.util.concurrent API, introduced in Java 5.0, to Java 1.4, and from Java 6.0 to Java 5.0"
HOMEPAGE="http://www.mathcs.emory.edu/dcl/util/backport-util-concurrent/"
SRC_URI="!java5? ( http://dcl.mathcs.emory.edu/util/${PN}/dist/${P}/Java14/${P}-src.zip )
	java5? ( http://dcl.mathcs.emory.edu/util/${PN}/dist/${P}/Java50/${PN}-Java50-${PV}-src.zip )"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc java5 source test"

DEPEND="java5? ( =virtual/jdk-1.5* )
	!java5? ( =virtual/jdk-1.4* )
	dev-java/ant-core
	dev-java/junit"
RDEPEND="java5? ( =virtual/jdk-1.5* )
	!java5? ( =virtual/jre-1.4* )"

if use java5 ; then
	S="${WORKDIR}/${PN}-Java50-${PV}-src"
else
	S="${WORKDIR}/${P}-src"
fi

src_unpack() {
	unpack ${A}
	cd ${S}/external
	rm -f *.jar
	java-pkg_jar-from junit
}

src_compile() {
	eant javacompile archive $(use_doc)
}

src_test() {
	eant test
}

src_install() {
	java-pkg_dojar ${PN}.jar
	use doc && java-pkg_dojavadoc doc/api
	use source && java-pkg_dosrc src/*
	java-pkg_dohtml README.html
}
