# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jmi-interface/jmi-interface-1.0.ebuild,v 1.3 2005/06/09 00:57:02 mr_bones_ Exp $

inherit java-pkg

DESCRIPTION="Java Metadata Interface Sample Class Interface"
HOMEPAGE="http://java.sun.com/products/jmi/"
JMI_ZIP="jmi-${PV/./_}-fr-interfaces.zip"
MOF_XML="mof-${PV}.xml.bz2"
SRC_URI="mirror://gentoo/${JMI_ZIP}
		 mirror://gentoo/${MOF_XML}"

LICENSE="sun-bcla-jmi"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE="doc jikes source"

DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	jikes? ( dev-java/jikes )
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}

src_unpack() {
	unpack ${MOF_XML}
	mv ${MOF_XML/.bz2/} mof.xml

	cp ${FILESDIR}/${P}-build.xml ${S}/build.xml

	mkdir ${S}/src
	unzip -q -d ${S}/src ${DISTDIR}/${JMI_ZIP}
}

src_compile() {
	local antflags="compile"
	use doc && antflags="${antflags} javadoc"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant ${antflags} || die "Failed to compile"

	#adding mof.jar required by Netbeans #98603
	cd ${S}/build/javax/jmi/model/
	mkdir resources
	cd resources
	mv ${WORKDIR}/mof.xml .

	cd ${S}
	ant jar || die "Failed to build jar files"
}

src_install() {
	use doc && java-pkg_dohtml -r doc/*
	use source && java-pkg_dosrc src/*
	dojar dist/*.jar
}
