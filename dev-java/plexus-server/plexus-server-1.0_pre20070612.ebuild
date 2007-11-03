# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_MAVEN_BOOTSTRAP="Y"
inherit java-pkg-2 java-maven-2

DESCRIPTION="The Plexus project provides a full software stack for creating and executing software projects."
HOMEPAGE="http://plexus.codehaus.org/"
SRC_URI="http://dev.gentooexperimental.org/~kiorky/${P}.tar.bz2"
LICENSE="as-is" # http://plexus.codehaus.org/plexus-utils/license.html
SLOT="0"
KEYWORDS="~x86"
IUSE="source doc"
COMMON_DEPS="
dev-java/velocity
=dev-java/dnsjava-1.3.2*
>=dev-java/plexus-container-default-1.0_alpha33_pre20071021
>=dev-java/plexus-component-api-1.0_alpha33_pre20071021
"
DEPEND=">=virtual/jdk-1.4 	${COMMON_DEPS}"
RDEPEND=">=virtual/jre-1.4	${COMMON_DEPS}"
EANT_EXTRA_FLAGS="-Dproject.name=${PN}"
JAVA_MAVEN_CLASSPATH="
plexus-component-api-1.0_alpha33
plexus-container-default-1.0_alpha33
dnsjava-1.3.2
velocity
"
JAVA_MAVEN_PROJECTS="
plexus-server-core
plexus-servers/plexus-server-dns
plexus-servers/plexus-server-ftp
plexus-servers/plexus-server-http
plexus-servers/plexus-server-irc
plexus-servers/plexus-server-smtp
plexus-servers/plexus-server-pop
plexus-servers
"

