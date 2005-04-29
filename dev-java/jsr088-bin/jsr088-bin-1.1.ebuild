# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="J2EE Application Deployment Specification"

HOMEPAGE="http://java.sun.com/j2ee/tools/deployment/"

MY_PV=${PV/./_}

SRC_URI="mirror://gentoo/j2ee_deployment-${MY_PV}-fr-class.zip
		doc? ( mirror://gentoo/j2ee_deployment-${MY_PV}-fr-doc.zip )"

LICENSE="sun-bcla-jsr088"

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

	use doc && java-pkg_dohtml -r doc/*
	
	dojar ${PN}.jar
}
