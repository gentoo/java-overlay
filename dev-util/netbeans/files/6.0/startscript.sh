#!/bin/bash

check_symlinks() {
	for file in `find ${1} -type l` ; do

		if ! test -e ${file} ; then
			echo "Broken symlink:"
			echo "${file}"
		fi

	done
}

NBDIR="/usr/share/netbeans-6.0"

check_symlinks ${NBDIR}/ide8/modules/ext
check_symlinks ${NBDIR}/ide8/modules/autoload/ext
check_symlinks ${NBDIR}/enterprise4/config/TagLibraries/JSTL11
check_symlinks ${NBDIR}/platform7/modules/ext

${NBDIR}/bin/netbeans "$@"
