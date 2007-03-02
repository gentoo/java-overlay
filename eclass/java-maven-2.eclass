# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

JAVA_MAVEN_VERSION=${WANT_MAVEN_VERSION:=1}
SLOT="${JAVA_MAVEN_VERSION}"

case "${JAVA_MAVEN_VERSION}" in
	"1")
		JAVA_MAVEN_EXEC="/usr/bin/maven-1"
		;;
	"1.1")
		JAVA_MAVEN_EXEC="/usr/bin/maven-1.1"
		;;

	"2")
		JAVA_MAVEN_EXEC="/usr/bin/mvn"
		;;
esac

JAVA_MAVEN_SYSTEM_HOME="/usr/share/maven-${SLOT}/maven_home"

# maven 1 and 1.1 share the same repo
JAVA_MAVEN_SYSTEM_REPOSITORY="/usr/share/maven-${SLOT//1.1/1}/maven_home/gentoo-repo"
JAVA_MAVEN_SYSTEM_PLUGINS="${JAVA_MAVEN_SYSTEM_HOME}/plugins"
JAVA_MAVEN_SYSTEM_BIN="${JAVA_MAVEN_SYSTEM_HOME}/bin"
JAVA_MAVEN_SYSTEM_LIB="${JAVA_MAVEN_SYSTEM_HOME}/lib"

JAVA_MAVEN_BUILD_HOME=${JAVA_MAVEN_BUILD_HOME:="${T}/.maven"}
JAVA_MAVEN_BUILD_REPO=${JAVA_MAVEN_BUILD_REPO:="${JAVA_MAVEN_BUILD_HOME}/repository"}
JAVA_MAVEN_BUILD_PLUGINS=${JAVA_MAVEN_BUILD_PLUGINS:="${JAVA_MAVEN_BUILD_HOME}/plugins"}

JAVA_MAVEN_OPTS="${JAVA_MAVEN_OPTS} -Dmaven.home.local=${JAVA_MAVEN_BUILD_HOME}"
JAVA_MAVEN_OPTS="${JAVA_MAVEN_OPTS} -Dmaven.plugin.dir=${JAVA_MAVEN_BUILD_PLUGINS}"
JAVA_MAVEN_OPTS="${JAVA_MAVEN_OPTS}	-Dmaven.repo.remote=file:/${JAVA_MAVEN_BUILD_REPO}"
JAVA_MAVEN_OPTS="${JAVA_MAVEN_OPTS} -Dmaven.repo.remote=file:/${JAVA_MAVEN_SYSTEM_REPOSITORY}"

emaven() {
	local gcp="${EMAVEN_GENTOO_CLASSPATH}"
	local cp

	for atom in ${gcp}; do
		cp="${cp}:$(java-pkg_getjars ${atom})"
	done

	local 	maven_flags="${maven_flags} -Dmaven.plugin.dir=${JAVA_MAVEN_BUILD_PLUGINS}"
			maven_flags="${maven_flags} -Dmaven.home.local=${JAVA_MAVEN_BUILD_HOME}"
			maven_flags="${maven_flags} -Dmaven.repo.local=${JAVA_MAVEN_BUILD_REPO}"
			maven_flags="${maven_flags} -DsystemClasspath${cp}"

	# TODO launch with scope system and systemClasspath set
	# launching (offline mode, we dont get anything !)
	${JAVA_MAVEN_EXEC} ${maven_flags} "-o $@" || die "maven failed"
}

# in case we re using maven1, we will need to generate
# a build.xml to apply our classpath
javava-maven-2-m1-gen_build_xml() {
	# generate build.xml whereever there is a project.xml
	for project in $(find "${WORKDIR}" -name project*xml);do
		cd $(dirname ${project}) || die
		emaven ant:ant\
			|| die "Generation of build.xml failed for ${project}"
	done
}

# searching for maven style generated ant build files
# rewrite their classpath and prevent them to use bundled jars !
# Separated from javava-maven-2-m1-gen_build_xml as we
# don't have always the ant plugin !
java-maven-2-rewrite_build_xml() {
		for build in $(find "${WORKDIR}" -name build*xml);do
		java-ant_rewrite-classpath "$build"
		# get out of classpath errors at build/test time
		sed -i "${build}" -re\
			's/pathelement\s*path="\$\{testclassesdir\}"/pathelement path="\$\{gentoo.classpath\}:\$\{testclassesdir\}"/'\
			|| die
		# separate compile and test time
		sed -i "${build}" -re\
			's/compile,test/compile/'\
			|| die
		# don't get bundled jars
		sed -i "${build}" -re\
			's/depends=\"get-deps\"//'\
			|| die
		# don't uset bundled jars
		sed -i "${build}" -re\
			's/refid=\"build.classpath\"/path=\"\$\{gentoo.classpath\}\"/'\
			|| die
	done
}

java-maven-2_m1_src_unpack() {
	base_src_unpack
	java-maven-2-m1-gen_build_xml
	java-maven-2-rewrite_build_xml
}

java-maven-2_src_test() {
	emaven test || die "Tests failed"
}

# in most cases we re safe, there is one jar but it can be
# either versionnated  or "SNAPSHOTED"
java-maven-2_src_install() {
	java-pkg_newjar target/*.jar ${PN}.jar
	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc src/java/*
}

EXPORT_FUNCTIONS src_test src_install
