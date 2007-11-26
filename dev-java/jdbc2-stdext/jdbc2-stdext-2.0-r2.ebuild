# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jdbc2-stdext/jdbc2-stdext-2.0-r2.ebuild,v 1.5 2007/07/11 19:58:38 mr_bones_ Exp $

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2

stdext_src="jdbc2_0-stdext-src.zip"
stdext_jar="jdbc2_0-stdext.jar"

DESCRIPTION="A standard set of libs for Server-Side JDBC support"
HOMEPAGE="http://java.sun.com/products/jdbc"
SRC_URI="${stdext_src}"
LICENSE="sun-bcla-jdbc2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""
RESTRICT="fetch"
DEPEND="app-arch/unzip
		>=virtual/jdk-1.3"
RDEPEND=">=virtual/jre-1.3"

S="${WORKDIR}"

pkg_nofetch() {
	einfo
	einfo " Due to license restrictions, we cannot fetch the"
	einfo " distributables automagically."
	einfo
	einfo " 1. Visit http://java.sun.com/products/jdbc/download.html#spec'"
	einfo " 2. Select 'JDBC 2.0 Optional Package Source'"
	einfo " 3. Download ${stdext_src}"
	einfo " 4. Move to ${DISTDIR}"
	einfo
	einfo " Run emerge on this package again to complete"
	einfo
}

src_unpack() {
	mkdir src
	cd src
	unpack ${A}
}

src_compile() {
	mkdir classes
	ejavac -d classes src/javax/sql/*.java
	jar cf "${stdext_jar}" -C classes/ . || die "jar failed"

	if use doc; then
		javadoc -d api -source $(java-pkg_get-source) -sourcepath src/ \
			javax.sql || die "javadoc failed"
	fi
}

src_install() {
	java-pkg_dojar "${stdext_jar}"

	use doc && java-pkg_dojavadoc api
	use source && java-pkg_dosrc src/*
}
