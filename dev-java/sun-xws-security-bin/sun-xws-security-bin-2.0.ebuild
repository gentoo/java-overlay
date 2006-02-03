# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JWSDP_VERSION="2.0"
JWSDP_DESC="XML and Web Services Security"

inherit java-wsdp

KEYWORDS="~x86"

DEPEND="${DEPEND}
	dev-java/sun-jaxrpc-bin"
