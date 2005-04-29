# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="J2EE Application Deployment Specification"

HOMEPAGE="http://java.sun.com/j2ee/tools/deployment/"

SRC_URI="j2ee_deployment-1_1-fr-class.zip
		doc? ( j2ee_deployment-1_1-fr-doc.zip 
			   j2ee_deployment-1_1-fr-spec.pdf )"

LICENSE="sun-bin"

SLOT="0"

KEYWORDS="~x86"

IUSE="doc"

DEPEND="virtual/jdk"

RDEPEND="virtual/jre"

S=${WORKDIR}

src_compile() {
	jar cvf ${PN}.jar javax
}

src_install() {
	if use doc; then
		dodoc ${DISTDIR}/j2ee_deployment-1_1-fr-spec.pdf
		java-pkg_dohtml -r doc/*
	fi
	dojar ${PN}.jar
}
