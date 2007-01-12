# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Java implementation of the JavaScript Object Notation"
HOMEPAGE="http://www.json.org"
SRC_URI="http://www.json.org/java/json.zip"

LICENSE="json"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	mkdir src
	mv org src/
	cp ${FILESDIR}/build.xml .
}

src_compile() {
	ant dist $(use_doc javadoc)
}

src_install() {
	java-pkg_dojar dist/lib/json.jar

	use doc && java-pkg_dojavadoc javadoc
}
