#!/bin/sh
#
# bootstrap.sh
#
# Pull down, build, and install all dependencies for twilio library.
#
# Caveats:
#  - It is assumed that ocaml is already installed in PREFIX
#  - If you want to build twilio-lwt, you will need to install lwt
#    as well.
#
SETUPDIR=$1
PREFIX=$2

if [ -z $PREFIX ]; then
    echo "Usage: bootstrap.sh <setupdir> <prefix>"
    echo "       <setupdir> - the directory to build libraries"
    echo "       <prefix> - the base directory to install libraries"
    exit 1
fi

req () {
    echo "=================================================================="
    echo " $2"
    echo "=================================================================="
    echo ""
    curl -L -v $1/$2.tar.gz -o $2.tar.gz && tar -xzvf $2.tar.gz && rm $2.tar.gz
}

##########################################################################
##FN=ocaml-ssl-0.4.5
##cd ${SETUPDIR}
##req http://sourceforge.net/projects/savonet/files/ocaml-ssl/0.4.5 $FN
##cd $FN
##./configure --prefix=${PREFIX}
##make
##make install
##
##########################################################################
##FN=ocamlnet-3.4
##cd ${SETUPDIR}
##req http://download.camlcity.org/download $FN
##cd $FN
##./configure -disable-pcre -enable-ssl
##make
##make install
##
##########################################################################
##FN=cppo
##cd ${SETUPDIR}
##req http://martin.jambon.free.fr $FN
##cd $FN
##make PREFIX=${PREFIX}
##make PREFIX=${PREFIX} install
##
##########################################################################
##FN=easy-format
##cd ${SETUPDIR}
##req http://martin.jambon.free.fr $FN
##cd $FN
##make
##make install
##
##########################################################################
##FN=biniou
##cd ${SETUPDIR}
##req http://martin.jambon.free.fr $FN
##cd $FN
##make
##make install
##
##########################################################################
##FN=yojson
##cd ${SETUPDIR}
##req http://martin.jambon.free.fr $FN
##cd $FN
##make
##make install
##
##########################################################################
##FN=menhir-20110201
##cd ${SETUPDIR}
##req http://pauillac.inria.fr/~fpottier/menhir $FN
##cd $FN
##make PREFIX=${PREFIX}
##make PREFIX=${PREFIX} install
##
########################################################################
cd ${SETUPDIR}
git clone https://github.com/MyLifeLabs/atd
cd atd && make && make install

########################################################################
cd ${SETUPDIR}
git clone https://github.com/MyLifeLabs/atdgen
cd atdgen && make && make -B install
