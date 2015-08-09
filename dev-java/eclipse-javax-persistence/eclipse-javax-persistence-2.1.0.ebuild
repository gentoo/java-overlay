# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="Eclipse implementation of persistence API 2.1 (JSR 338)"
HOMEPAGE="http://eclipse.org/eclipselink/"
SRC_URI="https://repo1.maven.org/maven2/org/eclipse/persistence/javax.persistence/${PV}/javax.persistence-${PV}-sources.jar"
LICENSE="EPL-1.0"
SLOT="2.1"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="dev-java/osgi-core-api:0"

RDEPEND=">=virtual/jre-1.5
	${CDEPEND}"

DEPEND=">=virtual/jdk-1.5
	${CDEPEND}"

JAVA_GENTOO_CLASSPATH="osgi-core-api"

java_prepare() {
	mkdir -p target/classes || die
	ln -s ../../{META,OSGI}-INF target/classes/ || die
}

src_install() {
	java-pkg-simple_src_install
	dodoc about.html readme.html
}
