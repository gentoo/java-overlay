# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit gradle

DESCRIPTION="A project automation and build tool with a Groovy based DSL"
SRC_URI="https://github.com/${PN}/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

HOMEPAGE="https://www.gradle.org/"
LICENSE="Apache-2.0"
SLOT="${PV}"
KEYWORDS="~amd64 ~x86"

DEPEND="
	app-eselect/eselect-gradle
"
RDEPEND=">=virtual/jdk-1.8:*"

# Hopefully we can remove network-sandbox at one point in the future
# from RESTRICT. But for now, it is necessary.
RESTRICT="network-sandbox"

src_compile() {
	if ! I_KNOW_THAT_DEV_JAVA_GRADLE_DOES_NOT_YET_WORK; then
		die "You don't know that dev-java/gradle does not yet work"
	fi

	local gradle_dir="${ED}/usr/share/${PN}-${SLOT}"

	egradle install "-Pgradle_installPath=${gradle_dir}"

	egradle :distributions-full:binDistributionZip
	egradle assemble
}

src_install() {
	local gradle_dir="${ED}/usr/share/${PN}-${SLOT}"

	egradle install "-Pgradle_installPath=${gradle_dir}"
}

pkg_postinst() {
	eselect gradle update ifunset
}

pkg_postrm() {
	eselect gradle update ifunset
}
