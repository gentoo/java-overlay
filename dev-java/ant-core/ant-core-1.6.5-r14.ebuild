# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-core/ant-core-1.6.5-r13.ebuild,v 1.4 2006/07/22 20:48:47 nelchael Exp $

inherit java-pkg-2 eutils toolchain-funcs java-ant-2

MY_PN=${PN/-core}

DESCRIPTION="Java-based build tool similar to 'make' that uses XML configuration files."
HOMEPAGE="http://ant.apache.org/"
SRC_URI="mirror://apache/ant/source/apache-${MY_PN}-${PV}-src.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="doc source"

DEPEND="${RDEPEND}
	source? ( app-arch/zip )
	>=virtual/jdk-1.4"
RDEPEND=">=virtual/jdk-1.4
	>=dev-java/java-config-1.2"

S="${WORKDIR}/apache-ant-${PV}"

src_unpack() {
	unpack ${A}
	cd ${S}
	
	# remove bundled xerces
	rm lib/*.jar
	
	# Patch build.sh to die with non-zero exit code in case of errors.
	# This patch may be useful for all ant versions.
	epatch ${FILESDIR}/build.sh-exit-fix.patch
}

src_compile() {
	if [[ $(tc-arch) == "ppc" ]] ; then
		# We're compiling _ON_ PPC
		export THREADS_FLAG="green"
	fi

	./build.sh -Ddist.dir=${D}/usr/share/${PN} || die "failed to build"

	if use doc; then
		./build.sh dist_javadocs || die "failed to build docs"
	fi
}

src_install() {
	newbin ${FILESDIR}/${PV}-ant ant || die "failed to install wrapper"

	dodir /usr/share/${PN}/bin
	for each in antRun runant.pl runant.py complete-ant-cmd.pl ; do
		dobin ${S}/src/script/${each}
		dosym /usr/bin/${each} /usr/share/${PN}/bin/${each}
	done

	dodir /etc/env.d
	echo "ANT_HOME=\"/usr/share/${PN}\"" > ${D}/etc/env.d/20ant

	java-pkg_dojar build/lib/ant.jar
	java-pkg_dojar build/lib/ant-launcher.jar

	use source && java-pkg_dosrc src/main/*

	dodoc README WHATSNEW KEYS
	use doc && dohtml welcome.html
	use doc && java-pkg_dohtml -r docs/*
	# put javadocs into the right place per bug #112106
	use doc && java-pkg_dohtml -r dist/docs/*
}
