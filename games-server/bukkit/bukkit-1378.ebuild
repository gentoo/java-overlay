# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
COMMIT="1317a37"
BUKKIT_API="1.2.3-R0.1"
JAVA_PKG_IUSE="doc source"

inherit games java-pkg-2 java-pkg-simple

DESCRIPTION="Generic API component of the plugin-based server mod for Minecraft"
HOMEPAGE="http://bukkit.org"
SRC_URI="https://github.com/Bukkit/Bukkit/tarball/${COMMIT} -> ${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="dev-java/commons-lang:2.1
	dev-java/ebean:0
	dev-java/guava:10
	>=dev-java/snakeyaml-1.9:0"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.6"

RDEPEND="${CDEPEND}
	>=dev-java/json-simple-1.1:0
	>=virtual/jre-1.6"

S="${WORKDIR}/Bukkit-Bukkit-${COMMIT}"

JAVA_GENTOO_CLASSPATH="commons-lang-2.1 ebean guava-10 snakeyaml"
JAVA_SRC_DIR="src/main/java"

java_prepare() {
	# Easier to use java-pkg-simple.
	rm -v pom.xml || die

	mkdir -p target/classes/META-INF/maven/org.bukkit/bukkit || die
	echo "version=${BUKKIT_API}" > target/classes/META-INF/maven/org.bukkit/bukkit/pom.properties || die
}

src_install() {
	java-pkg_register-dependency json-simple
	java-pkg-simple_src_install
	dodoc README.md || die
}
