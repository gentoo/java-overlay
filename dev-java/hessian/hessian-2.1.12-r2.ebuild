# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/hessian/hessian-2.1.12-r2.ebuild,v 1.2 2007/01/16 17:17:52 betelgeuse Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="A binary web service protocol."
HOMEPAGE="http://www.caucho.com/hessian/"
SRC_URI="http://www.caucho.com/hessian/download/${P}-src.jar"

LICENSE="Apache-1.1"
SLOT="2.1"
KEYWORDS="~amd64 ~x86"
IUSE="doc source"

COMMON_DEP=" =dev-java/servletapi-2.3*
		=dev-java/caucho-services-${PV}*"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
# FIXME doesn't like Java 1.5 XML APIs
DEPEND="=virtual/jdk-1.4*
	source? ( app-arch/zip )
	dev-java/ant-core
	${COMMON_DEP}"

src_unpack() {
	jar xvf ${DISTDIR}/${A}

	# We need to move things around a bit
	mkdir -p ${S}/src
	mv com ${S}/src

	rm -fr ${S}/src/com/caucho/services

	cd ${S}
	# No included ant script! Bad Java developer, bad!
	cp ${FILESDIR}/build-${PV}.xml build.xml

	# Populate classpath
	local classpath="classpath=$(java-pkg_getjars servletapi-2.3)"
	classpath="${classpath}:$(java-pkg_getjars caucho-services-2.1)"
	echo ${classpath} >> build.properties
}

src_compile() {
	eant -Dproject.name=${PN} jar $(use_doc)
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dohtml -r dist/doc/api
	use source && java-pkg_dosrc src/*
}
