#!/bin/bash

check_symlinks() {
	for file in `find ${1} -type l` ; do

		if ! test -e ${file} ; then
			echo "Broken symlink:"
			echo "${file}"
		fi

	done
}

NBDIR="/usr/share/netbeans-5.5"

check_symlinks ${NBDIR}/ide7/modules/ext
check_symlinks ${NBDIR}/ide7/modules/autoload/ext
check_symlinks ${NBDIR}/enterprise3/config/TagLibraries/JSTL11
check_symlinks ${NBDIR}/platform6/modules/ext

${NBDIR}/bin/netbeans "$@"
