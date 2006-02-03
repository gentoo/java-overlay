# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JWSDP_VERSION="2.0"
JWSDP_DESC="Java Web Services Developer Pack (Java WSDP)"

inherit java-wsdp

KEYWORDS="~x86"

DEPEND="sun-fastinfoset-bin
	sun-jaxb-bin
	sun-jaxp-bin
	sun-jaxr-bin
	sun-jaxrpc-bin
	sun-jaxws-bin
	sun-jwsdp-shared-bin
	sun-saaj-bin
	sun-sjsxp-bin
	sun-xmldsig-bin
	sun-xws-security-bin"

src_unpack() {

	use doc && java-wsdp_src_unpack

}

src_install() {

	if use doc; then
		cd "${WORKDIR}/base"
		einfo "Installing documentation..."
		java-pkg_dohtml -r docs/*
	fi

}
