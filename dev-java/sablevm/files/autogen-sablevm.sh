#!/bin/sh

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# * This source file is part of SableVM.                            *
# *                                                                 *
# * See the file "LICENSE" for the copyright information and for    *
# * the terms and conditions for copying, distribution and          *
# * modification of this source file.                               *
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

aclocal && \
libtoolize --force && \
autoconf && \
autoheader && \
automake --foreign -a -c && \
echo "You can now run ./configure."
