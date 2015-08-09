# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="1"

WANT_ANT_TASKS="dev-java/jflex:0"
JAVA_PKG_IUSE="doc source"

inherit eutils java-pkg-2 java-ant-2

MY_P="${P}-src"

DESCRIPTION="Small embeddable pure Java library for syntax highlighting"
HOMEPAGE="https://jhighlight.dev.java.net/"
SRC_URI="https://jhighlight.dev.java.net/files/documents/3366/30845/${MY_P}.zip"
LICENSE="|| ( CDDL LGPL-2.1 )"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=">=virtual/jre-1.4
	java-virtuals/servlet-api:2.3"
DEPEND=">=virtual/jdk-1.4
	java-virtuals/servlet-api:2.3
	app-arch/unzip"

S="${WORKDIR}/${MY_P}"

EANT_DOC_TARGET="javadocs"

src_unpack() {
	unpack ${A}
	cd "${S}/lib/" || die
	rm -rv *.jar || die
	java-pkg_jar-from --virtual servlet-api-2.3
}

src_install() {
	java-pkg_newjar build/dist/${P}.jar ${PN}.jar
	use doc && java-pkg_dojavadoc build/javadocs/jhighlight-javadocs-${PV}/docs/api/
	use source && java-pkg_dosrc src/com
}
