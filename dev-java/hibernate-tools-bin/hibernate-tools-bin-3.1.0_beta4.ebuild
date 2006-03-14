# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg versionator

MY_PN="HibernateTools"
MY_PV="$(replace_version_separator 3 .)"
MY_P="${MY_PN}-${MY_PV}"
DESCRIPTION="Tools for dealing with Hibernate from Ant and Eclipse"
HOMEPAGE="http://tools.hibernate.org"
SRC_URI="mirror://sourceforge/jboss/${MY_P}.zip"
# http://prdownloads.sourceforge.net/jboss/HibernateTools-3.1.0.beta4.zip?download
LICENSE=""
SLOT="3.1"
KEYWORDS="~amd64 ~x86"
IUSE="eclipse"

S="${WORKDIR}"

DEPEND="virtual/jdk"
RDEPEND="virtual/jre
	eclipse? (
		dev-eclipse/eclipse-wst
		dev-eclipse/eclipse-emf
		dev-eclipse/eclipse-gef
		dev-eclipse/eclipse-jem
	)"


PLUGIN_DIR="plugins/org.hibernate.eclipse_3.1.0.beta4"
FEATURE_DIR="features/org.hibernate.eclipse.feature_3.1.0.beta4"
src_unpack() {
	unpack ${A}

	# TODO replace packed jars
}

src_install() {
	java-pkg_dojar ${PLUGIN_DIR}/lib/tools/hibernate-tools.jar

	if use eclipse; then
		insinto /usr/lib/eclipse-extensions-3.1/eclipse/plugins/
		doins -r plugins/org.hibernate.eclipse*
		insinto /usr/lib/eclipse-extensions-3.1/eclipse/features/
		doins -r ${FEATURE_DIR}
	fi
}
