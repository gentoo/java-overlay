# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/gjdoc/gjdoc-0.7.9.ebuild,v 1.1 2008/04/22 13:57:59 betelgeuse Exp $

EAPI=1

inherit eutils autotools java-pkg-2

DESCRIPTION="A javadoc compatible Java source documentation generator."
HOMEPAGE="http://www.gnu.org/software/cp-tools/"
SRC_URI="mirror://gnu/classpath/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86 ~x86-fbsd"

# Possible USE flags.
#
# doc:    to generate javadoc
# debug:  There is a debug doclet installed by default but maybe could
#         have a wrapper that uses it.
#
IUSE="xmldoclet gcj"

RDEPEND=">=virtual/jre-1.4
	>=dev-java/antlr-2.7.1
	gcj? ( dev-java/gcj-jdk )"

# Refused to emerge with sun-jdk-1.3* complaining about wanting a bigger stack size
DEPEND="${RDEPEND}
		>=virtual/jdk-1.4"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-0.7.7-gcp.patch"
	AT_M4DIR="m4" eautoreconf
}

src_compile() {
	local myc="--with-antlr-jar=$(java-pkg_getjar antlr antlr.jar)"
	myc="${myc} --disable-dependency-tracking"

		# TODO ideally, would respect JAVACFLAGS
	JAVA="java" JAVAC="javac $(java-pkg_javac-args)" \
		econf ${myc} \
		$(use_enable xmldoclet) \
		$(use_enable gcj native) || die "econf failed"

	emake || die "emake failed"
}

src_install() {
	local jars="com-sun-tools-doclets-Taglet gnu-classpath-tools-gjdoc com-sun-javadoc"
	for jar in ${jars}; do
		java-pkg_newjar ${jar}-${PV}.jar ${jar}.jar
	done

	dodoc AUTHORS ChangeLog NEWS README

	cd "${S}"/docs
	emake DESTDIR="${D}" install || die "Failed to install documentation"

	if use gcj ; then
		exeinto /usr/bin
		newexe "${S}"/.libs/gjdoc native_gjdoc
		dolib.so "${S}"/.libs/*.so*
	fi
	dobin "${FILESDIR}"/gjdoc

	use source && java-pkg_dosrc "${S}/src"/{com,gnu}
}
