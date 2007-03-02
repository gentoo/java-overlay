# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit jboss-4-tmp eutils java-ant-2

MY_P="jboss-${PV}"
MY_P="${MY_P}.GA-src"
MY_EJB3="jboss-EJB-3.0_RC9_Patch_1"
#thirdparty library

DESCRIPTION="An open source, standards-compliant, J2EE-based application server implemented in 100% Pure Java."

RESTRICT="nomirror"
HOMEPAGE="http://www.jboss.org"
LICENSE="LGPL-2"
IUSE="doc ejb3 srvdir"
SLOT="4"
KEYWORDS="~x86"
# jdk1.7 is not ready to use !
DEPEND="<virtual/jdk-1.7
		app-arch/unzip
		ejb3?  ( >=virtual/jdk-1.5 )
		!ejb3? ( >=virtual/jdk-1.4 )"
RDEPEND="${DEPEND}"
S=${WORKDIR}/${MY_P}

# NOTE: When you are updating CONFIG_PROTECT env.d file, you can use this script on your current install
# run from /var/lib/jboss-${SLOT} to get list of files that should be config protected. We protect *.xml,
# *.properties and *.tld files.
# SLOT="4" TEST=`find /var/lib/jboss-${SLOT}/ -type f | grep -E -e "\.(xml|properties|tld)$"`; echo $TEST
# by kiorky better:
# echo "CONFIG_PROTECT=\"$(find /srv/localhost/jboss-4/ -name "*xml" -or -name \
#          "*properties" -or -name "*tld" |xargs echo -n)\"">>env.d/50jboss-4
# NOTE:
# Status : working on eclass and dependencies mapping
#          mappings is quite finnished, eclass needs some work

# ------------------------------------------------------------------------------
# @function thirdparty_deps_get_xdoclet
#
# bring back xdoclet jars
#
# ------------------------------------------------------------------------------
thirdparty_deps_get_xdoclet() {
	DEST="${S}/thirdparty/xdoclet/lib"
	mkdir -p ${DEST}||die "mkdir dest failed"
	cd ${DEST}||die "failed change cwd"
	for jar in ${S}/thirdparty.old/xdoclet/lib/*;do
		jar=$(basename $jar)
		jarn="$(basename $jar -jb4.jar).jar"
		if [[ $jar == "xdoclet-xjavadoc-jb4.jar" ]];then
			thirdparty_dep_get_jars --jar xjavadoc.jar --rename $jar xdoclet xjavadoc
		else
			thirdparty_dep_get_jars --jar $jarn --rename $jar xdoclet xdoclet
		fi
	done
}

# ------------------------------------------------------------------------------
# @function thirdparty_use_bundled_jars
#
# bring back jboss thirdparty shipped jars
# Please only use when there is not any way to get and compile the sources
#
# @param $1 which dependency to get
# ------------------------------------------------------------------------------
thirdparty_use_bundled_jars() {
	ewarn "Bad: using bundled jar for $1"
	cp -rf "${S}/thirdparty.old/$1/" "${S}/thirdparty"\
			|| die "cp $1 failed"
}

src_unpack() {
	unpack ${A}
	cd ${S} || die "cd failed"
}

src_compile() {
	cd ${S}
}

