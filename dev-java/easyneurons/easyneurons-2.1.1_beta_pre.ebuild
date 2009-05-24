# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"
EAPI="2"

inherit java-pkg-2 java-ant-2

DESCRIPTION="GUI neural network editor for neuroph"
HOMEPAGE="http://neuroph.sourceforge.net/"
SRC_URI="http://neuroph.sourceforge.net/NeurophProjects.zip \
	-> NeurophProject-2.1.1_beta_pre.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""

#missing dep absolutelayout.jar
COMMON_DEP="dev-java/colt:0
	dev-java/appframework:0
	dev-java/commons-collections:0
	dev-java/absolutelayout:0
	dev-java/jung:0
	=dev-java/neuroph-${PV}"

RDEPEND=">=virtual/jre-1.6
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.6
	app-arch/unzip
	${COMMON_DEP}"

S="${WORKDIR}/NeurophProjects/${PN}/"

java_prepare() {
	rm -R "${WORKDIR}/NeurophProjects/neuroph"

	find "${WORKDIR}" -iname '*.jar' -delete
	find "${WORKDIR}" -iname '*.class' -delete
	java-pkg_jar-from --into lib commons-collections \
		commons-collections.jar commons-collections-3.2.1.jar
	#java-pkg_jar-from --into lib colt colt.jar
	java-pkg_jar-from --into lib appframework appframework.jar \
		appframework-1.0.3.jar
	java-pkg_jar-from --into lib jung jung.jar jung-1.7.6.jar
	java-pkg_jar-from --into lib absolutelayout absolutelayout.jar \
		AbsoluteLayout.jar
	mkdir -p ../neuroph/dist
	java-pkg_jar-from --into ../neuroph/dist neuroph
}

src_compile() {
	eant -Dno.deps=True -Dreference.neuroph=lib/neuroph.jar jar $(use_doc)
}

src_install() {
	java-pkg_dojar "dist/${PN}.jar"
	use doc && java-pkg_dojavadoc dist/javadoc
	use source && java-pkg_dosrc src

	java-pkg_dolauncher ${PN} \
		--main org.neuroph.easyneurons.EasyNeuronsApplication

}

