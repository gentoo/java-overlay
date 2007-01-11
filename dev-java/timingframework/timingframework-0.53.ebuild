# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

#TODO improve description
DESCRIPTION="Java Utility and Framework for timing and animations"
HOMEPAGE="https://timingframework.dev.java.net"
SRC_URI="https://${PN}.dev.java.net/files/documents/2564/48057/TimingFramework-${PV}-src.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"

DEPEND=">=virtual/jdk-1.5
		app-core/unzip
		dev-java/ant-core"
RDEPEND=">=virtual/jre-1.5"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	mkdir src
	mv org src/
	cp ${FILESDIR}/build.xml build.xml
}

src_compile() {
	eant dist $(use_doc javadoc)
}

src_install() {
	java-pkg_dojar dist/lib/timingframework.jar
	java-pkg_dojavadoc javadoc
}
