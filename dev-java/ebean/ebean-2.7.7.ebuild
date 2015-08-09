# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4
JAVA_PKG_IUSE="doc source"

inherit eutils java-pkg-2 java-pkg-simple

DESCRIPTION="An ORM for Java from Avaje"
HOMEPAGE="http://www.avaje.org/"
SRC_URI="mirror://sourceforge/ebeanorm/${P}.zip"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="scala"

CDEPEND="dev-java/ant-core:0
	dev-java/glassfish-persistence:0
	dev-java/glassfish-transaction-api:0
	dev-java/joda-time:0
	java-virtuals/servlet-api:2.5
	scala? ( dev-lang/scala )"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.6"

DEPEND="${CDEPEND}
	app-arch/unzip
	>=virtual/jdk-1.6"

S="${WORKDIR}/${P}"
JAVA_GENTOO_CLASSPATH="ant-core glassfish-persistence glassfish-transaction-api joda-time servlet-api-2.5"

pkg_setup() {
	java-pkg-2_pkg_setup
	use scala && JAVA_GENTOO_CLASSPATH="${JAVA_GENTOO_CLASSPATH} scala"
}

java_prepare() {
	unpack "./${P}-sources.jar"

	# Upstream JDBC code is targeted at 1.6.
	java-pkg_is-vm-version-ge 1.7 && epatch "${FILESDIR}/jdk7.patch"

	if ! use scala; then
		einfo "Removing Scala support ..."
		find -regex ".*/[^/]*Scala[^r][^/]*\.java" -exec rm -vf {} \; || die
		epatch "${FILESDIR}/no-scala.patch"
	fi
}

src_install() {
	java-pkg-simple_src_install
	java-pkg_register-optional-dependency jdbc-mysql,jdbc-postgresql,sqlite-jdbc,h2
	dodoc readme.txt
	newdoc "${PN}"-userguide{-*,}.pdf
}
