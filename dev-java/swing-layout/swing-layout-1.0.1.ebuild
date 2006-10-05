# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Professional cross platform layouts with Swing"
HOMEPAGE="https://swing-layout.dev.java.net/"
SRC_URI="https://swing-layout.dev.java.net/files/documents/2752/35842/${P}-src.zip"

LICENSE="LGPL-2.1"
SLOT="1"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
		>=dev-java/ant-core-1.5"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}

src_compile(){
	eant
}

src_install(){
	java-pkg_dojar dist/swing-layout.jar
	use_doc && java-pkg_dojavadoc dist/javadoc
}
