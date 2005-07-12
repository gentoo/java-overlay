# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

MY_PN=JacORB
MY_PV=${PV//./_}
MY_P="${MY_PN}_${MY_PV}"
DESCRIPTION="The free Java implementation of the OMG's CORBA standard."
HOMEPAGE="http://www.jacorb.org/"
SRC_URI="http://www.jacorb.org/releases/${PV}/${MY_P}-full.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
# Some patching will be needed for jikes support
IUSE="doc"

# TODO: test other vm's
# TODO: test if X is needed at runtime
DEPEND=">=virtual/jdk-1.4
	dev-java/ant
	jikes? (dev-java/jikes)
	virtual/x11"
RDEPEND=">=virtual/jre-1.4
	dev-java/antlr
	=dev-java/avalon-framework-4.1*
	dev-java/concurrent-util
	=dev-java/avalon-logkit-2.0*
	dev-java/wrapper
	dev-java/log4j"
S="${WORKDIR}/${MY_P}"

ANT_ANTLR="antlr antlr.jar antlr-2.7.2.jar"
AVALON_FRAMEWORK="avalon-framework-4.1 avalon-framework.jar avalon-framework-4.1.5.jar"
CONCURRENT="concurrent-util concurrent.jar concurrent-1.3.2.jar"
LOGKIT="avalon-logkit-2.0 avalon-logkit.jar logkit-1.2.jar"
WRAPPER="wrapper wrapper.jar wrapper-3.1.0.jar"

src_unpack() {
	unpack ${A}

	# For some reason, directories aren't executable
	find . -type d -exec chmod a+x {} \;

	cd ${S}

	einfo "Fixing jars in lib/"
	cd ${S}/lib
	rm *.jar
	java-pkg_jar-from ${ANT_ANTLR}
	java-pkg_jar-from ${AVALON_FRAMEWORK}
	java-pkg_jar-from ${CONCURRENT}
	java-pkg_jar-from ${LOGKIT} 
	java-pkg_jar-from ${WRAPPER}
}

src_compile() {
	# TODO patch build.xml's clean to delete this package's jars
	#rm lib/{idl,jacorb}.jar || die "Failed to clean build directory"

	local antflags="all core_jacorb_jar jacorb_services_jar omg_services_jar \
	http_tunneling_jar security_jar"
	use doc && antflags="${antflags} doc"
	ant ${antflags} || die "Ant failed"

	cd ${S}/bin
	rm -f *.bat *template* *.exe
}

src_install() {
	# TODO: install bins?

	cd ${S}/doc
	dodoc REL_NOTES Coding.txt
	dohtml *.html
	if use doc; then
		java-pkg_dohtml -r api
	fi

	cd ${S}/lib
	java-pkg_dojar core_jacorb.jar http_tunneling.jar idl.jar jacorb.jar \
		jacorb_services.jar omg_services.jar security.jar
}
