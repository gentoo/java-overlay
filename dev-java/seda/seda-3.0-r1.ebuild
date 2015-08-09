# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit java-pkg-2 java-ant-2

MY_P="${PN}-release-20020712"

DESCRIPTION="A robust, high-performance platform for Internet services"
HOMEPAGE="http://www.eecs.harvard.edu/~mdw/proj/seda/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"

IUSE="doc source"

RDEPEND=">=virtual/jre-1.3"
DEPEND=">=virtual/jdk-1.3
		source? ( app-arch/zip )"

BASE="${WORKDIR}/${MY_P}/${PN}"
S="${BASE}/src/${PN}"

src_compile() {

	for dir in "${S}/nbio/jni" "${S}/util/jni"; do
		cd ${dir}
		econf --with-jdk="$(java-config --jdk-home)" || die "Failed to run configure in ${dir}."
	done

	local classpath="${CLASSPATH}:${BASE}/src:."

	cd ${S}

	CLASSPATH="${classpath}" \
	LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${BASE}/lib" \
		emake || die "Compiling failed."
	
	local jar=$(java-config -j)

	find . -name '*.class' -type f -print0 | xargs -0 \
		${jar} cf ${WORKDIR}/${PN}.jar || die "Creating ${PN}.jar failed"	

	if use doc; then
		cd ${BASE}/docs/javadoc

		CLASSPATH="${classpath}" make \
			|| die "Failed to generate documentation."
	fi
}

src_install() {
	java-pkg_doso ${BASE}/lib/*.so
	java-pkg_dojar ${WORKDIR}/*.jar
	dodoc ${BASE}/README
	use doc && java-pkg_dohtml -r ${BASE}/docs/*
	use source && java-pkg_dosrc ${S}/{nbio,sandStorm,util}
}
