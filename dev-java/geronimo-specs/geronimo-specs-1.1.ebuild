# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-utils-2

# change order with care, it controls the build order !
SPECS="activation jta ejb servlet jsp saaj jaxr jaxrpc commonj
	   corba corba-2.3 corba-3.0 j2ee-connector j2ee-deployment
	   j2ee-jacc j2ee-management javamail jaxr jms qname"

DESCRIPTION="Apache's Geronimo implementation of J2EE specification"
HOMEPAGE="http://geronimo.apache.org"
SRC_URI="activation? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-activation-${PV}.tar.bz2 )
	commonj? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-commonj-${PV}.tar.bz2 )
	corba? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-corba-${PV}.tar.bz2 )
	corba-2.3? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-corba-2.3-${PV}.tar.bz2 )
	corba-3.0? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-corba-3.0-${PV}.tar.bz2 )
	ejb? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-ejb-${PV}.tar.bz2 )
	j2ee? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-j2ee-${PV}.tar.bz2 )
	j2ee-connector? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-j2ee-connector-${PV}.tar.bz2 )
	j2ee-deployment? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-j2ee-deployment-${PV}.tar.bz2 )
	j2ee-jacc? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-j2ee-jacc-${PV}.tar.bz2 )
	j2ee-management? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-j2ee-management-${PV}.tar.bz2 )
	javamail? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-javamail-${PV}.tar.bz2 )
	jaxr? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-jaxr-${PV}.tar.bz2 )
	jaxrpc? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-jaxrpc-${PV}.tar.bz2 )
	jms? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-jms-${PV}.tar.bz2 )
	jsp? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-jsp-${PV}.tar.bz2 )
	jta? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-jta-${PV}.tar.bz2 )
	qname? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-qname-${PV}.tar.bz2 )
	saaj? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-saaj-${PV}.tar.bz2 )
	servlet? ( http://dev.gentooexperimental.org/~kiorky/geronimo-spec-servlet-${PV}.tar.bz2 )
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 "
IUSE="source ${SPECS}"
DEPEND=">=virtual/jdk-1.4
		=dev-java/jacorb-2.2*"
RDEPEND="${DEPEND} >=virtual/jre-1.4"
S=${WORKDIR}

pkg_setup() {
	# must choose at least one spec to ebuild
	local stop = "y"
	for i in ${SPECS};do
		if use $i;then
			stop = "n"
		fi
	done
	[[ ${stop} == "y" ]] &&\
	 eerror "You must choose at least one spec to build in ${SPECS}, add it to the geronimo-specs USES"
}

src_compile(){
	local build="${WORKDIR}/build" dist="${WORKDIR}/dist"
	local classpath="-cp "
	classpath="${classpath}:$(java-pkg_getjars jacorb-2.2)"
	mkdir -p "${build}" "${dist}" || die "mkdir failed"
	for i in ${SPECS}; do
		if use $i; then
			einfo "Building $i Specification"
			mkdir -p ${build}/$i || die "mkdir spec $i failed"
			classpath="${classpath}:${build}/$i"
			ejavac ${classpath} -nowarn -d "${build}/$i" \
				$(find	"${S}/geronimo-spec-$i-${PV}/src/main/java" -name "*.java")\
				|| die "failed to build $i"
			[[ -d "${S}/geronimo-spec-$i-${PV}/src/main/resources/" ]] && \
				cp -rf "${S}/geronimo-spec-$i-${PV}/src/main/resources"/* \
				"${build}/$i" || die "cp rss failed"
			jar cf "${dist}/geronimo-spec-$i.jar" -C "${build}/$i" . || die "failed too create jar"
		fi
	done
}

src_install() {
	local dist="${WORKDIR}/dist"
	cd "${dist}" || die "cd failed"
	java-pkg_dojar *jar
	for i in ${SPECS}; do
		if use $i; then
			use source && java-pkg_dosrc "${S}/geronimo-spec-$i-${PV}/src/main/java"
		fi
	done
}

