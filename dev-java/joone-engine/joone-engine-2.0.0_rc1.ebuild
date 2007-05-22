# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Java Object Oriented Neural Engine"
HOMEPAGE="http://www.jooneworld.com/"
SRC_URI="mirror://sourceforge/joone/${PN}-src-${PV/_rc/RC}.zip"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND="dev-java/velocity dev-java/poi dev-java/bsh =dev-java/groovy-1* dev-java/log4j"

RDEPEND=">=virtual/jre-1.4
	dev-java/xstream
	${COMMON_DEPEND}"

DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	${COMMON_DEPEND}"

S="${WORKDIR}"

src_unpack() {
	unpack "${A}"
	cd "${S}"
	mkdir releases
	rm -rv joone/org/joone/samples || die
	# Fix for http://sourceforge.net/forum/message.php?msg_id=3632500 #
	rm joone/org/joone/net/NestedNeuralLayerBeanInfo.java || die
	rm joone/org/joone/util/SnapshotRecorderBeanInfo.java || die
	###################################################################
	epatch "${FILESDIR}/ioexception.patch"
	cd joone || die
	epatch "${FILESDIR}/jartarget.patch"
	cd ..
	mv joone/build.xml . || die
	java-ant_rewrite-classpath
}

EANT_GENTOO_CLASSPATH="velocity,poi,groovy-1,bsh,log4j"
EANT_BUILD_TARGET="jar-engine"
EANT_DOC_TARGET="doc"
EANT_EXTRA_ARGS="-Dbase=."

src_install() {
	java-pkg_dojar ${PN}.jar
	java-pkg_register-dependency xstream
	use doc && java-pkg_dojavadoc doc/api
	use source && java-pkg_dosrc joone/*
}
