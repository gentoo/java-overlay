# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils versionator java-pkg-2 java-ant-2

MY_PN=JacORB
#MY_PV=$(replace_all_version_separators _ )
MY_P="${MY_PN}-${PV}"
DESCRIPTION="The free Java implementation of the OMG's CORBA standard."
HOMEPAGE="http://www.jacorb.org/"
SRC_URI="http://www.jacorb.org/releases/${PV}/${MY_P}-source.tar.gz"

LICENSE="GPL-2"
SLOT="2.2"
#KEYWORDS="-*"
KEYWORDS="~amd64 ~x86"
# Some patching will be needed for jikes support
IUSE="doc"

# TODO: test if X is needed at runtime
# TODO: re-add X dep, with modular-X deps
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	jikes? ( dev-java/jikes )"
RDEPEND=">=virtual/jre-1.4
	dev-java/antlr
	=dev-java/avalon-framework-4.1*
	dev-java/concurrent-util
	=dev-java/avalon-logkit-2.0*
	=dev-java/java-service-wrapper-3.1*
	=dev-java/picocontainer-1.1*
	dev-java/log4j
	dev-java/backport-util-concurrent"
S="${WORKDIR}/${MY_P}"

ANTLR="antlr antlr.jar antlr-2.7.2.jar"
AVALON_FRAMEWORK="avalon-framework-4.1 avalon-framework.jar avalon-framework-4.1.5.jar"
CONCURRENT="concurrent-util concurrent.jar concurrent-1.3.2.jar"
LOGKIT="avalon-logkit-2.0 avalon-logkit.jar logkit-1.2.jar"
WRAPPER="java-service-wrapper-3.1 wrapper.jar wrapper-3.1.0.jar"
PICOCONTAINER="picocontainer-1 picocontainer.jar picocontainer-1.2.jar"

src_unpack() {
	unpack ${A}

	cd ${S}  || die "cd failed"

	# workaround for a test which dont want do rewrite his build.xml
	rm -rf ${S}/test	|| die "rm fautive test	failed"

	# patch build.xml to put jars into dist/
	# TODO submit upstream
	epatch ${FILESDIR}/${P}-dist.patch

	cd ${S}/lib || die "cd failed"
	rm *.jar || die "rm failed"
	java-pkg_jar-from ${ANTLR}
	java-pkg_jar-from ${AVALON_FRAMEWORK}
	java-pkg_jar-from ${CONCURRENT}
	java-pkg_jar-from ${LOGKIT}
	java-pkg_jar-from ${WRAPPER}
	java-pkg_jar-from ${PICOCONTAINER}
	java-pkg_jar-from backport-util-concurrent
}

src_compile() {
	local antflags="realclean all core_jacorb_jar jacorb_services_jar omg_services_jar \
	security_jar"
	use doc && antflags="${antflags} doc"

	# Need to up maximum memory to avoid OutOfMemoryErrors
	ANT_OPTS="${ANT_OPTS} -Xmx512m" \
		eant ${antflags}

	cd ${S}/bin || die "cd failed"
	rm -f *.bat *template* *.exe || die "rm exe failed"
}

src_install() {
	java-pkg_dojar dist/*.jar

	cd ${S}/bin || die "cd failed"
	local binlist=$(grep -l /bin/sh * | grep -v .template)
	dobin ${binlist}

	cd ${S}/doc || die "cd failed"
	dodoc REL_NOTES Coding.txt
	dohtml *.html
	use doc && java-pkg_dohtml -r api
}
