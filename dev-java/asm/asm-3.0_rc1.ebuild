# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/asm/asm-2.0-r1.ebuild,v 1.2 2006/07/22 21:26:56 nelchael Exp $

inherit java-pkg-2 java-ant-2

MY_PV="${PN}-3.0_RC1"
S="${WORKDIR}/${MY_PV}"

DESCRIPTION="Bytecode manipulation framework for Java"
HOMEPAGE="http://asm.objectweb.org"
SRC_URI="http://download.forge.objectweb.org/${PN}/${MY_PV}.tar.gz"
LICENSE="BSD"
SLOT="3"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc source"
DEPEND=">=virtual/jdk-1.5
	dev-java/ant-core
	dev-java/ant-owanttask
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.5"

src_unpack() {
	unpack ${A}

	cd ${S}
	echo "objectweb.ant.tasks.path = $(java-pkg_getjar --build-only ant-owanttask ow_util_ant_tasks.jar)" >> build.properties
}

src_compile() {
	eant jar $(use_doc jdoc)
}

src_install() {
	for x in output/dist/lib/*.jar ; do
		java-pkg_newjar ${x} $(basename ${x/-3.0_RC1})
	done
	use doc && java-pkg_dohtml -r output/dist/doc/javadoc/user/*
	use source && java-pkg_dosrc src/*
}

