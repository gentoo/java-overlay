# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

WANT_ANT_TASKS="ant-pretty"

inherit jboss-4-tmp java-pkg-2 java-ant-2

DESCRIPTION="Common module of JBoss Application Server"
SRC_URI="${BASEURL}/${P}.tar.bz2 ${ECLASS_URI}"
IUSE=""
KEYWORDS="~amd64 ~x86"
#JAVA_PKG_DEBUG=1

DEPEND="=virtual/jdk-1.4*"
RDEPEND=">=virtual/jre-1.4"
S="${WORKDIR}/jboss-${PV}-src"
#EANT_GENTOO_CLASSPATH="log4j"

src_unpack() {
	jboss-4_src_unpack
	# do like that as there is some relative path in build.xml fucking up
	# java-ant_rewrite-classpath
	for build in $(find "${S}" -name build*.xml );do
		#fix relative path causing java-ant_rewrite-classpath to fail
		sed -ire\
			"s:../tools/etc/buildfragments/:${S}/tools/etc/buildmagic/:g" \
			"$build" || die "sed failed"
		java-ant_rewrite-classpath ${build}
	done
}
