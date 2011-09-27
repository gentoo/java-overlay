# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="A YAML 1.1 parser and emitter for Java 5"
HOMEPAGE="http://code.google.com/p/snakeyaml/"
SRC_URI="http://snakeyaml.googlecode.com/files/SnakeYAML-all-${PV}.zip"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="dev-java/gdata:0"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.5"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.5"

S="${WORKDIR}/${PN}"
JAVA_SRC_DIR="src/main/java"

java_prepare() {
	# Remove bundled stuff.
	rm -r target "${JAVA_SRC_DIR}/com" || die
}

src_configure() {
	# gdata has a lot of JARs. Be specific.
	JAVA_CLASSPATH_EXTRA="$(java-pkg_getjar gdata gdata-core.jar)"
}

src_install() {
	java-pkg-simple_src_install
	dodoc AUTHORS src/etc/announcement.msg || die
}
