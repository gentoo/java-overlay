# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jgoodies-looks/jgoodies-looks-1.3.2.ebuild,v 1.2 2005/12/10 07:06:15 compnerd Exp $

inherit java-pkg-2 java-ant-2

MY_V=${PV//./_}
DESCRIPTION="JGoodies Looks Library"
HOMEPAGE="http://www.jgoodies.com/"
SRC_URI="http://www.jgoodies.com/download/libraries/looks-${MY_V}.zip"

LICENSE="BSD"
SLOT="2.0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc"

RDEPEND="dev-java/jgoodies-forms"
DEPEND=">=virtual/jdk-1.4.2
	dev-java/ant-core
	app-arch/unzip
	${RDEPEND}"
RDEPEND=">=virtual/jre-1.4.2
	${RDEPEND}"

S="${WORKDIR}/looks-${PV}"

src_unpack() {
	unpack ${A} || die "Unpack failed!"
	cd ${S}
	sed -e "s/bootclasspath=\"\${build.boot.classpath}\"//" -i build.xml
	rm -v lib/*.jar
}

src_compile() {
	# jar target fails unless we make descriptors.dir and existing directory
	# I checked the ustream binary distribution and they also don't actually
	# put anything there.
	# 31.7.2006 betelgeuse@gentoo.org

	local forms=$(java-pkg_getjar jgoodies-forms forms.jar)
	local antflags="-Dlib.forms.jar=\"${forms}\" -Ddescriptors.dir=\"${S}\""
	eant ${antflags} $(use_doc) jar
}

src_install() {
	java-pkg_newjar looks-${PV}.jar looks.jar

	dodoc RELEASE-NOTES.txt
	use doc && java-pkg_dohtml -r build/docs/*
}
