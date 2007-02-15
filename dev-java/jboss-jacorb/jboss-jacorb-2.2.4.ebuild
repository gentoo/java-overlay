# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-ant-2

MY_PN=JacORB
MY_P="${MY_PN}-${PV}"
DESCRIPTION="The free Java implementation of the OMG's CORBA standard with jboss patches"
HOMEPAGE="http://www.jacorb.org/"
SRC_URI="http://dev.gentooexperimental.org/~kiorky/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2.2"
KEYWORDS="~x86"
# Some patching will be needed for jikes support
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	jikes? ( dev-java/jikes )"
RDEPEND=">=virtual/jre-1.4
	dev-java/antlr
	=dev-java/avalon-framework-4.1*
	dev-java/concurrent-util
	=dev-java/avalon-logkit-2.0*
	=dev-java/java-service-wrapper-3.1*
	>=dev-java/picocontainer-1.2_beta1
	dev-java/log4j
	>dev-java/mx4j-3.0.1
	dev-java/backport-util-concurrent"

S="${WORKDIR}/${MY_PN}"

ANTLR="antlr antlr.jar antlr-2.7.2.jar"
AVALON_FRAMEWORK="avalon-framework-4.1 avalon-framework.jar avalon-framework-4.1.5.jar"
CONCURRENT="concurrent-util concurrent.jar concurrent-1.3.2.jar"
LOGKIT="avalon-logkit-2.0 avalon-logkit.jar logkit-1.2.jar"
WRAPPER="java-service-wrapper-3.1 wrapper.jar wrapper-3.1.0.jar"
PICOCONTAINER="picocontainer-1 picocontainer.jar picocontainer-1.2.jar"

EANT_GENTOO_CLASSPATH="picocontainer-1"
EANT_EXTRA_ARGS="-Dmx4j.home=/usr/share/mx4j-core/lib"
EANT_DOC_TARGET="doc"
EANT_BUILD_TARGET="realclean all core_jacorb_jar jacorb_services_jar \
omg_services_jar security_jar"

src_unpack() {
	unpack ${A}
	cd "${S}" || die "cd failed"

	# workaround for a test which dont want do rewrite his build.xml
	rm -rf "${S}/test" || die "rm fautive test	failed"

	# patch build.xml to put jars into dist/
	epatch ${FILESDIR}/${P}-dist.patch
	epatch ${FILESDIR}/${P}-jboss_adds.patch

	cd "${S}/lib" || die "cd failed"
	rm *.jar || die "rm failed"
	java-pkg_jar-from ${ANTLR}
	java-pkg_jar-from ${AVALON_FRAMEWORK}
	java-pkg_jar-from ${CONCURRENT}
	java-pkg_jar-from ${LOGKIT}
	java-pkg_jar-from ${WRAPPER}
	java-pkg_jar-from mx4j-core-3.0
	java-pkg_jar-from ${PICOCONTAINER}
	java-pkg_jar-from backport-util-concurrent

	# Need to up maximum memory to avoid OutOfMemoryErrors
	export ANT_OPTS="${ANT_OPTS} -Xmx512m"

	for b in $(find "${S}" -name build.xml);do
		java-ant_rewrite-classpath "$b"
	done
}

src_install() {
	java-pkg_dojar dist/*.jar
	cd "${S}/bin" || die "cd failed"
	rm -f *.bat *template* *.exe || die "rm exe failed"
	local binlist=$(grep -l /bin/sh * | grep -v .template)
	dobin ${binlist}
	cd "${S}/doc" || die "cd failed"
	dodoc REL_NOTES Coding.txt
	dohtml *.html
	use doc && java-pkg_dohtml -r api
}
