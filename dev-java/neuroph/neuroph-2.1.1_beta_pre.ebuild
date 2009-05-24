# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"
EAPI="2"

inherit java-pkg-2 java-ant-2

DESCRIPTION="A lightweight Java neural network framework"
HOMEPAGE="http://neuroph.sourceforge.net/"
SRC_URI="http://neuroph.sourceforge.net/NeurophProjects.zip \
	-> NeurophProject-2.1.1_beta_pre.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""

RDEPEND=">=virtual/jre-1.6"
DEPEND=">=virtual/jdk-1.6
	app-arch/unzip"

S="${WORKDIR}/NeurophProjects/${PN}/"

java_prepare() {
	find "${WORKDIR}" -iname '*.jar' -delete
	find "${WORKDIR}" -iname '*.class' -delete
}

EANT_BUILD_TARGET="jar"
EANT_DOC_TARGET="javadoc"

src_install() {
	java-pkg_dojar "dist/${PN}.jar"
	use doc && java-pkg_dojavadoc dist/javadoc
	use source && java-pkg_dosrc src
}

