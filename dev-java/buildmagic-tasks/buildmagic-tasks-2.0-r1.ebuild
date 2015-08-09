# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="JBoss buildmagic tasks module"
HOMEPAGE="http://www.jboss.org"
BASE_URL="http://gentooexperimental.org/distfiles"
#BASE_URL="mirror://gentoo"
# These source files were obtained from jpackage's srpm for
# jboss4-buildmagic-tasks
SRC_URI="${BASE_URL}/jboss-buildmagic-${PV}.tar.gz ${BASE_URL}/jboss-common-4.0.0.DR4.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="dev-java/log4j
	>=dev-java/bsf-2.3"
DEPEND=">=virtual/jdk-1.4
	${CDEPEND}"
RDEPEND=">=virtual/jre-1.4
	${CDEPEND}"
	
S="${WORKDIR}/buildmagic/tasks"

COMMON=${WORKDIR}/jboss-common

src_unpack() {
	unpack ${A}

	cd ${S}/..

	# TODO: make this into a patch
	# curtesy of jpackage.org
	cp tasks/build.xml tasks/build.xml.sav
	for f in `find tasks/src -name "*.java"`; do
		sed -e 's|com\.ibm\.bsf|org\.apache\.bsf|' $f > temp.java
		cp temp.java $f
	done
	rm temp.java

	# curtesy of jpackage.org
	epatch ${FILESDIR}/jboss4-buildmagic-tasks-build_xml.patch

	# in order to avoid a circular dependency with jboss-common, we need
	# to include the classes from jboss-common that we actually need
	# TODO: this most likely can be cleaned up with some for loops
	mkdir -p tasks/src/main/org/jboss/util/file
	mkdir -p tasks/src/main/org/jboss/util/platform
	mkdir -p tasks/src/main/org/jboss/util/stream
	mkdir -p tasks/src/main/org/jboss/logging
	cp ../jboss-common/src/main/org/jboss/util/DirectoryBuilder.java tasks/src/main/org/jboss/util
	cp ../jboss-common/src/main/org/jboss/util/Strings.java tasks/src/main/org/jboss/util
	cp ../jboss-common/src/main/org/jboss/util/NestedError.java tasks/src/main/org/jboss/util
	cp ../jboss-common/src/main/org/jboss/util/NestedThrowable.java tasks/src/main/org/jboss/util
	cp ../jboss-common/src/main/org/jboss/util/ThrowableHandler.java tasks/src/main/org/jboss/util
	cp ../jboss-common/src/main/org/jboss/util/ThrowableListener.java tasks/src/main/org/jboss/util
	cp ../jboss-common/src/main/org/jboss/util/NullArgumentException.java tasks/src/main/org/jboss/util
	cp ../jboss-common/src/main/org/jboss/util/EmptyStringException.java tasks/src/main/org/jboss/util
	cp ../jboss-common/src/main/org/jboss/util/file/Files.java tasks/src/main/org/jboss/util/file
	cp ../jboss-common/src/main/org/jboss/util/platform/Java.java tasks/src/main/org/jboss/util/platform
	cp ../jboss-common/src/main/org/jboss/util/stream/Streams.java tasks/src/main/org/jboss/util/stream
	cp ../jboss-common/src/main/org/jboss/logging/Logger.java tasks/src/main/org/jboss/logging
	cp ../jboss-common/src/main/org/jboss/logging/LoggerPlugin.java tasks/src/main/org/jboss/logging
	cp ../jboss-common/src/main/org/jboss/logging/NullLoggerPlugin.java tasks/src/main/org/jboss/logging
}

src_compile() {
	local antflags="output"
	antflags="-lib $(java-pkg_getjars bsf-2.3,log4j) ${antflags}"
	antflags="${antflags} \
		-Djavac.optimize=off \
		-Djavac.target=1.4 \
		-Djavac.debug=off \
		-Djavac.depend=no \
		-Djavac.verbose=no \
		-Djavac.deprecation=on \
		-Djavac.include.ant.runtime=yes \
		-Djavac.include.java.runtime=no \
		-Djavac.fail.onerror=true \
		-Djavac.includes=**/*.java \
		-Dsource.java=src \
		-Dsource.etc=src/etc \
		-Dsource.resources=src/resources \
		-Dbuild.classes=output/classes \
		-Dbuild.gen.classes=output/gen/classes \
		-Dbuild.etc=output/etc \
		-Dbuild.resources=output/resources \
		-Dbuild.lib=output/lib \
		-Dinit.disable=true \
		-Ddependency-manager.offline=true \
		-Dbuild.sysclasspath=only"

	eant ${antflags}
}

src_install() {
	java-pkg_dojar output/lib/buildmagic-tasks.jar
}
