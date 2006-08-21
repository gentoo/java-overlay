# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/avalon-logkit/avalon-logkit-1.2-r1.ebuild,v 1.2 2006/07/22 21:29:53 nelchael Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="LogKit is an easy-to-use Java logging toolkit designed for secure, performance-oriented logging."
HOMEPAGE="http://avalon.apache.org/"
SRC_URI="mirror://apache/avalon/logkit/v${PV}/LogKit-${PV}-src.tar.gz"
COMMON_DEP="
	javamail? (
		dev-java/sun-jaf
		dev-java/sun-javamail
	)
	jms? ( || (
				!ppc? ( dev-java/openjms )
				dev-java/sun-jms
               )
       )"
RDEPEND=">=virtual/jre-1.3
	${COMMON_DEP}"

# Doesn't like 1.5 changes to JDBC
DEPEND="|| (
		=virtual/jdk-1.3*
		=virtual/jdk-1.4*
		=virtual/jdk-1.5*
	)
	dev-java/ant-core
	dev-java/junit
	source? ( app-arch/zip )
	${COMMON_DEP}"

LICENSE="Apache-1.1"
SLOT="1.2"
KEYWORDS="~x86 ~amd64 ~ppc64 ~sparc ~ppc"
IUSE="doc javamail jms source"

S=${WORKDIR}/LogKit-${PV}

src_unpack() {
	unpack ${A}
	cd ${S}/lib
	rm -f *.jar

	# decide which mail implementation we use
	if use javamail; then
		java-pkg_jar-from sun-jaf
		java-pkg_jar-from sun-javamail
	fi

	# decide which jms implementation we use
	if use jms; then
		java-pkg_jar-from jms
	fi
}

src_compile() {
	# not generating api docs because we would 
	# need avalon-site otherwise
	eant jar -Djunit.jar=$(java-pkg_getjar junit junit.jar)
}

src_install() {
	java-pkg_dojar ${S}/build/lib/*.jar
	use doc && java-pkg_dohtml -r docs/*
	use source && java-pkg_dosrc src/java/*
}
