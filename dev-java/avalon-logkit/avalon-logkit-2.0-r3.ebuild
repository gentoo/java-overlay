# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/avalon-logkit/avalon-logkit-2.0-r1.ebuild,v 1.2 2006/07/22 21:29:53 nelchael Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Easy-to-use Java logging toolkit"
HOMEPAGE="http://avalon.apache.org/"
SRC_URI="mirror://apache/avalon/avalon-logkit/distributions/${P}.dev-0-src.tar.gz"
KEYWORDS="~x86 ~amd64 ~ppc64 ~sparc ~ppc"
LICENSE="Apache-2.0"
SLOT="2.0"
IUSE="doc jms javamail source"
COMMON_DEP="
	dev-java/log4j
	jms? ( || (
			dev-java/sun-jms
			!ppc? ( dev-java/openjms )
			)
	)
	javamail? ( 
		dev-java/sun-javamail
	)
	=dev-java/servletapi-2.4*"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
# Doesn't like 1.5 changes to JDBC
DEPEND="|| (
		=virtual/jdk-1.3*
		=virtual/jdk-1.4*
		=virtual/jdk-1.5*
	)
	source? ( app-arch/zip )
	dev-java/ant-core
	dev-java/junit
	${COMMON_DEP}"

S=${WORKDIR}/${P}.dev-0

src_unpack() {
	unpack ${A}
	cd ${S}

	# the build.xml file for ant
	cp ${FILESDIR}/${PV}-build.xml ./build.xml

	# decide which mail implementation we use
	local javamail=""
	if use javamail; then
		javamail="sun-javamail"
	fi

	# decide which jms implementation we use
	local jms=""
	if use jms; then
		if has_version dev-java/openjms; then
			jms="openjms"
		elif has_version dev-java/sun-jms; then
			jms="sun-jms"
		fi
	fi

	local libs="log4j,servletapi-2.4"
	use jms && libs="${libs},${jms}"
	use javamail && libs="${libs},${javamail}"

	echo "classpath=$(java-pkg_getjars ${libs})" > build.properties

	cd ${S}/src/java/org/apache/log/output/

	if ! use jms; then
		echo "Removing jms related files"
		rm -rf jms || die "JMS Failure!"
		rm -f ServletOutputLogTarget.java || die "JMS Failure!"
	fi

	if ! use javamail; then
		echo "Removing javamail related files"
		rm -rf net || die "JavaMail Failure!"
	fi
}

src_compile() {
	eant $(use_doc) jar
}

src_install() {
	java-pkg_dojar ${S}/dist/avalon-logkit.jar || die "Install Failed!"

	dodoc README.txt LICENSE.txt
	use doc && java-pkg_dohtml -r ${S}/dist/docs/*
	use source && java-pkg_dosrc src/java/*
}
