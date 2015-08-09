# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit java-pkg-2

DESCRIPTION="A project automation and build tool similar to Apache Ant and Apache Maven with a Groovy based DSL"
SRC_URI="http://services.gradle.org/distributions/${P}-src.zip"
HOMEPAGE="http://www.gradle.org/"
LICENSE="Apache-2.0"
SLOT="${PV}"
KEYWORDS="~amd64 ~x86"

DEPEND="app-arch/zip
	app-eselect/eselect-gradle"
RDEPEND=">=virtual/jdk-1.5"

src_compile() {
	gradle --gradle-user-home "$WORKDIR" install -Pgradle_installPath=dist || die
}

src_install() {
	cd dist || die
	dodoc changelog.txt getting-started.html

	local gradle_dir="${EROOT}usr/share/${PN}-${SLOT}"

	insinto "${gradle_dir}"

	# jars in lib/
	# Note that we can't strip the version from the gradle jars,
	# because then gradle won't find them.
	cd lib || die "lib/ not found"
	for jar in *.jar; do
		java-pkg_newjar ${jar} ${jar}
	done

	# plugins in lib/plugins
	cd plugins
	java-pkg_jarinto ${JAVA_PKG_JARDEST}/plugins
	for jar in *.jar; do
		java-pkg_newjar ${jar} ${jar}
	done

	java-pkg_dolauncher "${P}" --main org.gradle.launcher.GradleMain --java_args "-Dgradle.home=${gradle_dir}/lib \${GRADLE_OPTS}"
}

pkg_postinst() {
	eselect gradle update ifunset
}

pkg_postrm() {
	eselect gradle update ifunset
}
