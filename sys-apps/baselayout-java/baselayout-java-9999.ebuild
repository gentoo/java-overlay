# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools xdg-utils

DESCRIPTION="Baselayout for Java"
HOMEPAGE="https://www.gentoo.org/proj/en/java/"

if [[ "${PV}" == "9999" ]] || [[ -n "${EGIT_COMMIT_ID}" ]]; then
	EGIT_REPO_URI="https://anongit.gentoo.org/git/proj/baselayout-java.git"
	inherit git-r3
else
	SRC_URI="https://dev.gentoo.org/~gyakovlev/distfiles/${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~x86 ~amd64-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND="!!<dev-java/java-config-2.2"

BDEPEND="
	app-crypt/p11-kit[trust]
	app-misc/ca-certificates
"

RDEPEND="${BDEPEND}
	!<dev-java/java-config-2.2"

src_prepare() {
	default
	if [[ -n "${EGIT_REPO_URI}" ]]; then
		eautoreconf
	fi
}

src_install() {
	default
	keepdir /etc/ssl/certs/java/
	exeinto /etc/ca-certificates/update.d
	newexe - java-cacerts <<-_EOF_
		#!/bin/sh
		exec trust extract --overwrite --format=java-cacerts --filter=ca-anchors --purpose server-auth "${EPREFIX}/etc/ssl/certs/java/cacerts"
	_EOF_
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	# on first installation generate java cacert file
	# so jdk ebuilds can create symlink to in into security directory
	if [[ ! -f "${EROOT}"/etc/ssl/certs/java/cacerts ]]; then
		einfo "Generating java cacerts file from system ca-certificates"
		trust extract --overwrite --format=java-cacerts --filter=ca-anchors --purpose server-auth "${EROOT}/etc/ssl/certs/java/cacerts" || die
	fi
}
