# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-pkg-simple

MY_P="apache-log4j-${PV}-src"
DESCRIPTION="Core component of Java's Apache Log4j"
HOMEPAGE="http://logging.apache.org/log4j/"
SRC_URI="mirror://apache/logging/log4j/${PV}/${MY_P}.tar.gz"
LICENSE="Apache-2.0"
SLOT="2"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="test" # Too many missing deps :(

CDEPEND="dev-java/disruptor:0
	dev-java/eclipse-javax-persistence:2.1
	dev-java/jackson:2
	dev-java/jackson-annotations:2
	dev-java/jackson-databind:2
	dev-java/jackson-dataformat-xml:2
	dev-java/jackson-dataformat-yaml:2
	dev-java/log4j-api:2
	dev-java/osgi-core-api:0
	java-virtuals/javamail:0
	java-virtuals/jms:0"

RDEPEND=">=virtual/jre-1.6
	${CDEPEND}"

DEPEND=">=virtual/jdk-1.6
	${CDEPEND}"

S="${WORKDIR}/${MY_P}/${PN}/src"
JAVA_SRC_DIR="main/java"
JAVA_GENTOO_CLASSPATH="disruptor,eclipse-javax-persistence-2.1,jackson-2,jackson-annotations-2,jackson-databind-2,jackson-dataformat-xml-2,jackson-dataformat-yaml-2,javamail,jms,log4j-api-2,osgi-core-api"

java_prepare() {
	mkdir -p target/classes || die
	cd target/classes || die
	ln -s ../../main/resources/* . || die
}
