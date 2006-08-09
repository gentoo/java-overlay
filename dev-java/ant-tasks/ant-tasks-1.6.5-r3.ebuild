# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-tasks/ant-tasks-1.6.5-r2.ebuild,v 1.2 2006/07/22 23:09:33 flameeyes Exp $

inherit java-pkg-2 eutils

MY_PV=${PV/_/}
MY_P=${PN}-${MY_PV}

DESCRIPTION="Apache ANT Optional Tasks Jar Files"
HOMEPAGE="http://ant.apache.org/"
SRC_URI="mirror://apache/ant/source/apache-ant-${PV}-src.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc ~sparc ~ppc64"
IUSE="javamail noantlr nobcel nobeanutils nobsh nobsf nocommonsnet nocommonslogging nojdepend nojsch nojython nolog4j nooro noregexp norhino noxalan noxerces"

RDEPEND=">=virtual/jre-1.4
	=dev-java/ant-core-${PV}*
	!dev-java/ant-optional
	>=dev-java/junit-3.8
	!nolog4j? ( >=dev-java/log4j-1.2.8 )
	!noxerces? ( >=dev-java/xerces-2.6.2-r1 )
	!noxalan? ( >=dev-java/xalan-2.5.2 )
	!nobsh? ( >=dev-java/bsh-1.2-r7 )
	!nobsf? ( >=dev-java/bsf-2.3.0-r2 )
	!noantlr? ( >=dev-java/antlr-2.7.2 )
	!nobeanutils? ( =dev-java/commons-beanutils-1.6* )
	!nocommonslogging? ( >=dev-java/commons-logging-1.0.3 )
	!nocommonsnet? ( >=dev-java/commons-net-1.1.0 )
	!nobcel? ( >=dev-java/bcel-5.1 )
	!nooro? ( >=dev-java/jakarta-oro-2.0.8-r1 )
	!norhino? ( =dev-java/rhino-1.5* )
	!nojdepend? ( >=dev-java/jdepend-2.6 )
	!nojsch? ( >=dev-java/jsch-0.1.12 )
	!noregexp? ( >=dev-java/jakarta-regexp-1.3-r2 )
	!nojython? ( >=dev-java/jython-2.1-r5 )
	javamail? ( >=dev-java/sun-javamail-bin-1.3 )"
DEPEND=">=virtual/jdk-1.4
	>=dev-java/java-config-1.2
	${RDEPEND}"

S="${WORKDIR}/apache-ant-${MY_PV}"

src_compile() {
	addwrite "/proc/self/maps"
	if [[ $(uname -m) == "ppc" ]] ; then
		# We're compiling _ON_ PPC
		export THREADS_FLAG="green"
	fi

	local p="ant-core,junit" libs
	use noantlr || p="${p},antlr"
	use nobcel || p="${p},bcel"
	use nobeanutils || p="${p},commons-beanutils-1.6"
	use nobsh || p="${p},bsh"
	use nobsf || p="${p},bsf-2.3"
	use nocommonslogging || p="${p},commons-logging"
	use nocommonsnet || p="${p},commons-net"
	use nojdepend || p="${p},jdepend"
	use nojsch || p="${p},jsch"
	use nojython || p="${p},jython"
	use nolog4j || p="${p},log4j"
	use nooro || p="${p},jakarta-oro-2.0"
	use noregexp || p="${p},jakarta-regexp-1.3"
	use norhino || p="${p},rhino-1.5"
	use noxalan || p="${p},xalan"
	use noxerces || p="${p},xerces-2"

	use javamail && p="${p},sun-javamail-bin,sun-jaf-bin"

	CLASSPATH="${JAVA_HOME}/lib/tools.jar:.:$(java-pkg_getjars ant-core,${p})" java org.apache.tools.ant.launch.Launcher  -Dant.install=${ANT_HOME}
}

src_install() {
	for jar in build/lib/ant-*.jar; do
		[[ "$(basename ${jar})" == "ant-launcher.jar" ]] && continue
		java-pkg_dojar ${jar}
	done
}

pkg_postinst() {
	local noset=false
	for x in ${IUSE} ; do
		if [ "${x:0:2}" == "no" ] ; then
			use ${x} && noset=true
		fi
	done
	if [ ${noset} == "true" ]; then
		ewarn "You have disabled some of the ant tasks. Be advised that this may"
		ewarn "break building some of the Java packages!!"
		ewarn ""
		ewarn "We can only offer very limited support in cases where dev-java/ant-tasks"
		ewarn "has been build with essential features disabled."
	fi
}
