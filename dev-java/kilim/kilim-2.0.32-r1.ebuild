# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="Kilim is a generic configuration framework for Java, which can be used easily with existing applications, frameworks, and systems"
HOMEPAGE="http://kilim.objectweb.org/"
SRC_URI="http://download.forge.objectweb.org/${PN}2/${P//[.-]/_}-src.tar.gz"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.3
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.3
	dev-java/monolog
	=dev-java/mx4j-3.0*
	dev-java/log4j
	=dev-java/crimson-1*"

S=${WORKDIR}/Kilim${SLOT}

ant_src_unpack() {
	unpack ${A}

	cd ${S}
	epatch ${FILESDIR}/${P}-gentoo.patch

	cd ${S}/lib
	rm *.jar
	java-pkg_jar-from crimson-1
	java-pkg_jar-from mx4j-3.0
	java-pkg_jar-from log4j
	java-pkg_jar-from monolog ow_util_log_api.jar
	java-pkg_jar-from monolog ow_util_log_wrp_log4j.jar
}

src_compile() {
	eant jar $(use_doc)
}

src_install() {
	java-pkg_dojar lib/${PN}${SLOT}.jar
	use doc && java-pkg_dohtml -r doc/api
}
