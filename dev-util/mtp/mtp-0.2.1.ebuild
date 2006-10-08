# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="More Than Parsing - Parser and ASTs generator"
HOMEPAGE="http://babel.ls.fi.upm.es/research/mtp"
SRC_URI="http://babel.ls.fi.upm.es/software/mtp/${P}-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc examples"

RDEPEND=">=virtual/jre-1.4
	=dev-java/jsap-1.03a"
DEPEND=">=virtual/jdk-1.5
	dev-java/javacc
	=dev-java/jsap-1.03a
	>=dev-java/ant-core-1.6.2" # FIXME ant-core version

src_unpack()
{
	unpack ${A}

	cd ${S}/lib
	java-pkg_jarfrom jsap jsap.jar JSAP_1.03a.jar

}

src_compile() {
	# Apache ANT needs to know where JAVACC lives
	local javaccjar=$(java-pkg_getjar --build-only javacc javacc.jar)
	local javacc=$(dirname ${javaccjar})
	if (use doc) && $(built_with_use jsap doc); then
		local jsap_javadoc=$(javadoc-pkg_getjavadoc jsap)
	fi
	JAVACC=${javacc} JAVADOC_LINK=${jsap_javadoc} eant $(use_doc doc)
}

src_install() {
	# .jar files
	# TODO: patch ANT src/mtp/build.xml so that only one .jar file
	# is generated
	java-pkg_dojar lib/${PN}.jar
	java-pkg_dojar lib/${PN}ast.jar
	java-pkg_dojar lib/${PN}analysis.jar
	java-pkg_dojar lib/${PN}log.jar
	java-pkg_dojar lib/${PN}parser.jar
	java-pkg_dojar lib/${PN}semantics.jar
	java-pkg_dojar lib/${PN}synthesis.jar
	java-pkg_dolauncher ${PN} --main ${PN}.${PN}
	# Documentation
	if use doc; then
	    dodoc README
		ln -s docs api
	    java-pkg_dojavadoc api
	fi
	# Examples
	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp examples/* ${D}/usr/share/doc/${PF}/examples
	fi
}

# ------------------------------------------------------------------------------
# @ebuild-function java-pkg_getjavadoc
#
# Get the path of the javadoc documentation for a given package
# Returns -1 if no javadoc info is found
# Javadoc needs this in order to properly link files from different libraries
#
# Example: Get the path for JSAP javadoc documentation
#	java-pkg_getjars
# Example Return:
#	/usr/share/doc/JSAP-1.03a/doc/javadoc
#
# @param $1 - package to get the javadoc from
# ------------------------------------------------------------------------------
javadoc-pkg_getjavadoc() {
	debug-print-function ${FUNCNAME} $*

	[[ ${#} -ne 1 ]] && die "One and only one argument needed"

	local package_env=/usr/share/${1}/package.env
	local javadoc_dir

	javadoc_dir=-1
	if [[ -r "${package_env}" ]]; then
		exec 3<${package_env}
		local LINE
		while read LINE <&3 ; do
			if [[ $LINE == JAVADOC_PATH* ]]; then
				# Removing the JAVADOC_PATH=" part of the line
				javadoc_dir=${LINE#*=\"}
				javadoc_dir=${javadoc_dir/\"/}
			fi;
		done
	fi
	echo ${javadoc_dir}
}
