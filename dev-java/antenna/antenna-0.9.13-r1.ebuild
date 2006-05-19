# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit java-pkg-2 java-ant-2 eutils

MY_P=${DISTDIR}/${PN}-src-${PV}.zip

DESCRIPTION="Ant task for J2ME"
HOMEPAGE="http://antenna.sourceforge.net/"
SRC_URI="mirror://sourceforge/antenna/${PN}-src-${PV}.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4
	~dev-java/servletapi-2.3"

ant_src_unpack() {
	mkdir ${S} && cd ${S}

	unpack ${A}

	# Adds target dependencies and javadoc target
	# and removes any hardcoded paths in targets in favor of properties
	# TODO file upstream
	epatch ${FILESDIR}/${P}-ant.patch

	cat > build.properties <<-END
	project.name=${PN}
	project.version=${PV}
	classpath.servlet=$(java-pkg_getjars servletapi-2.3)
	END
}

src_compile() {
	eant jar $(use_doc)
}

src_install() {
	java-pkg_newjar dist/${PN}-bin-${PV}.jar ${PN}.jar

	dodir /usr/share/ant-core/lib/
	dosym /usr/share/${PN}/lib/${PN}.jar /usr/share/ant-core/lib/

	if use doc; then
		java-pkg_dohtml doc/*
		java-pkg_dohtml -r dist/doc/api
	fi
}
