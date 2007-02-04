# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="An appender to send logging event strings to a specified managment host"
HOMEPAGE="http://www.m2technologies.net/asp/snmpTrapAppender.asp"
MY_PN="snmpTrapAppender"
SRC_URI="http://www.m2technologies.net/bin/${MY_PN}_${PV//./_}.zip
		http://www.simpleweb.org/software/packages/snmpv3tk.zip
		"
LICENSE="Apache-1.1"
SLOT="0"
KEYWORDS="~x86"

IUSE="doc source"
JOESNMP_SLOT="0.3"
DEPEND=">=virtual/jdk-1.4
		source? ( app-arch/zip )
		dev-java/ant-tasks
		app-arch/unzip
		=dev-java/joesnmp-${JOESNMP_SLOT}*
		>=dev-java/log4j-1.2.13
		"
RDEPEND="${DEPEND}
		>=virtual/jre-1.4
		"
EANT_BUILD_TARGET="dist"
S=${WORKDIR}/${MY_PN}_${PV//./_}

src_unpack(){
	local l_workdir=""
	for i in  ${A};	do
		l_workdir=$(basename $i .zip)
		mkdir "${WORKDIR}/${l_workdir}" || die "src_unpack: mkdir ${l_workdir} failed"
		cd "${WORKDIR}/${l_workdir}"||die "src_unpack: cd ${l_workdir} failed"
		unpack $i
		find . -name "*class" -exec rm -rf '{}' \;\
			||"src_unpack: removing class files failed"
	done
	cd "${S}"|| die "src_unpack:cd ${S} failed"
	# getting  Dependencies
	java-pkg_jar-from joesnmp-${JOESNMP_SLOT}
	java-pkg_jar-from log4j
	cp -f "${FILESDIR}/${PV}/build.xml" .||die "src_unpack: cannot import ant build file"
}

src_install() {
	java-pkg_newjar dist/lib/${MY_PN}.jar
	use doc && java-pkg_dojavadoc dist/docs
	use source && java-pkg_dosrc src
}


