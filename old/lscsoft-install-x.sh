#!/bin/sh
### Run this script with argument --help to get a help message.
### Comments that begin with three hashes are not included in the
### documentation.  They are for the script only.

#cvsid
## $Id: lscsoft-install-x.sh 3534 2010-05-17 03:56:10Z ram $
#/cvsid

### Sample code fragments here... ignore them in the script.
#ignore
if false; then ###omit
#/ignore
##section Are these instructions for you?
##
## Are you using a Fedora, Red Hat, Debian or Mac OS X system?
## Do you have root password or can you get the ear of your sysadmin?
## If yes (to both) then you do not need to build the LSC software tools
## yourself: you can download and install the binary versions!
## Just follow the instructions at
## <a href=download/repositories.html>Download &gt; Repositories</a>
## to install the required software for LSC data analysis.
##
## However, if you are using some other system, or if you need to install
## the software in your home directory, then you can build the software from
## source.  These are the instructions for you.
##
## Please note that these instructions are out of date and may lead to
## strange build issues.
##
##section Introduction
##
## This document provides step-by-step instructions for installing standard
## LSC software required for various LSC data analysis libraries and tools.
##
## This documentation has been auto-extracted from a shell script that can
## be run.  The shell script will perform the exact instructions listed in
## the documentation, with a few switches controlled by command line arguments.
## use the "--help" command line argument to view these switches.
## You should not need to edit the shell script for it to work.
##
## Instead of running the script, you can, if you like, follow these
## instructions.  In general, you can cut-and-paste the directions directly
## into a shell.  There are a few modifications you may need to make,
## however.
##
## If you are using a C-shell [tcsh] rather than a Bourne shell [bash], the
## syntax for setting shell variables is slightly different.  Instead of
#verbatim
VARIABLE=value
export VARIABLE
#/verbatim
## you will need to type
#verbatim
setenv VARIABLE value
#/verbatim
## (even when there is no "export VARIABLE" instruction).
##
## Some of the instructions involve downloading software from a URL.
## These instructions use the command "curl" to do this.  If you don't
## have "curl", you can simply replace it with "wget -O-" or "lynx -source"
## in these instructions (provided you have "wget" or "lynx").  You can
## do this easily by using an alias.  If you are using bash, do:
#verbatim
alias curl="wget -O-"
#/verbatim
## while if you are using tcsh, do:
#verbatim
alias curl "wget -O-"
#/verbatim
#ignore
fi ###/omit
#/ignore


### Functions for the script only... ignore in documentation
#ignore


### the script name
program="$0"


### function to determine if running as root
is_root() {
  test `id | sed 's/^.*uid=\([0-9]*\).*$/\1/'` -eq 0
}


### prints the help message contained in variable helpmsg for the program
### contained in variable program
helpmsg="

usage: $program [options] mode"
print_usage() {
  echo "$helpmsg"
  return 0
}


### prints an error message given by the argument $1
print_error() {
  echo "error: $1" 1>&2
  exit 1
}


### simple failure
fail() {
  echo "!!! failure" 1>&2
  exit 1
}


### replacement for curl: uses wget or lynx if curl is not found
curl() {
  cmd="`which curl`"
  if test -x "$cmd" ; then
    $cmd "$1"
    return
  fi
  cmd="`which wget`"
  if test -x "$cmd" ; then
    $cmd -O- "$1"
    return
  fi
  cmd="`which lynx`"
  if test -x "$cmd" ; then
    $cmd -source "$1"
    return
  fi
  print_error "no curl, wget, or lynx found"
}


### function that will create an uninstall script
capture_uninstall() {
uninstall_file=${1:-"uninstall.sh"}
test -f $uninstall_file && rm -f $uninstall_file
echo '#!/bin/sh' > $uninstall_file
orig_rm=`which rm`
cat > rm <<EOF
echo "rm \$*" 1>&3
exit 0
EOF
chmod +x rm
save_PATH=$PATH
PATH=`pwd`:$PATH
export PATH
make uninstall 3>>$uninstall_file
PATH=$save_PATH
export PATH
echo "rm -f $uninstall_file" >> $uninstall_file
chmod +x $uninstall_file
$orig_rm -f rm
return 0
}


### sets variable LSCSOFT_LOCATION to argument (if required)
set_LSCSOFT_LOCATION() {
  if test -z "$LSCSOFT_LOCATION" ; then
    LSCSOFT_LOCATION=${1:-"${HOME}/opt/lscsoft"}
  fi
  return 0
}


### sets variable REDHAT_VERSION to argument (if required)
set_REDHAT_VERSION() {
  if test -z "$REDHAT_VERSION" ; then
    REDHAT_VERSION="${1:-"`cat /etc/redhat-release`"}"
  fi
  ### make sure it is one of the allowed values
  case $REDHAT_VERSION in
    "Red Hat Linux release 9 "* | redhat-9 | rh9 | 9) REDHAT_VERSION="9" ;;
    "Fedora Core release 2"* | fedora-2 | fc2) REDHAT_VERSION="fc2" ;;
    *) print_error "unrecognized redhat version $REDHAT_VERSION" ;;
  esac
  return 0
}


### reads the arguments and parses them, setting various environment variables 
### as requested
helpmsg="$helpmsg

options:
"
helpmsg="$helpmsg
  --help                        print a help message and exit"
helpmsg="$helpmsg
  --quiet                       silent execution: only print error messages"
helpmsg="$helpmsg
  --verbose                     verbose execution: echo every command"
helpmsg="$helpmsg

modes:
"
helpmsg="$helpmsg
  --from-debian                 install from binary Debian packages"
helpmsg="$helpmsg
  --from-rpm=REDHAT_VERSION     install from binary RPMs of for redhat version
                                REDHAT_VERSION"
helpmsg="$helpmsg
  --from-tar=LSCSOFT_LOCATION   build from source archives in LSCSOFT_LOCATION"
helpmsg="$helpmsg

environment variables:

        REDHAT_VERSION          version of Red Hat Linux used to build the rpm;
                                choices are:

                                        \"9\"   Red Hat Linux release 9
                                        \"fc2\" Fedora Core release 2

                                default is obtained from the contents of
                                /etc/redhat-release

        LSCSOFT_LOCATION        location to install software built from
                                source archives; default is \$HOME/opt/lscsoft
"
parse_args() {
  mode="none"
  verbose="false"
  while test $# -gt 0; do
    option=$1
    case $option in
      -*=*) optarg=`echo "$option" | sed 's/[-_a-zA-Z0-9]*=//'` ;;
      *) optarg= ;;
    esac
    case $option in
      -h | -help | --help) print_usage; exit 0;;
      -q | -quiet | --quiet) exec 1>/dev/null;;
      -v | -verb* | --verb*) verbose="true";;
      -d | -deb* | --deb* | -from-deb* | --from-deb*) mode="deb";;
      -r | -rpm | --rpm | -from-rpm | --from-rpm \
      | -r=* | -rpm=* | --rpm=* | -from-rpm=* | --from-rpm=*)
        set_REDHAT_VERSION "$optarg"; mode="rpm";;
      -t | -tar | --tar | -from-tar | --from-tar \
      | -t=* | -tar=* | --tar=* | -from-tar=* | --from-tar=*)
        set_LSCSOFT_LOCATION "$optarg"; mode="tar";;
      *) print_error "unrecognized option $option" ;;
    esac
    shift
  done
  test "$verbose" = "true" && set -x
}


### alert to setup environment for debian packages
print_deb_environment_setup_message() {
cat <<EOF
========================================================================

Add the following to your /etc/apt/sources.list:

        deb http://www.lsc-group.phys.uwm.edu/daswg/lscsoft/debian/\\
                testing main contrib non-free
        deb-src http://www.lsc-group.phys.uwm.edu/daswg/lscsoft/debian/\\
                testing main contrib non-free

========================================================================
EOF
}


### alert to setup environment to for custom-built sources
print_tar_environment_setup_message() {
cat <<EOF
========================================================================

To setup your environment to use the software that has been installed
please add the following to your .profile:

        LSCSOFT_LOCATION=$LSCSOFT_PREFIX
        export LSCSOFT_LOCATION
        . \${LSCSOFT_LOCATION}/lscsoft-user-env.sh

If you are using a C shell (e.g., tcsh), instead add these lines to
your .login:

        setenv LSCSOFT_LOCATION $LSCSOFT_PREFIX
        source \${LSCSOFT_LOCATION}/lscsoft-user-env.csh

========================================================================
EOF
}
#/ignore
### End of functions that are for the script only.


### Instructions for building from .DEB distributions
#ignore
deb_install() {
cat <<EOF
This option has been deprecated.
To install the LSC software on your Debian system, follow the instructions at:
http://www.lsc-group.phys.uwm.edu/daswg/download/repositories.html#debian
EOF
return 0
}
#/ignore


### Instructions for building from .RPM distributions
#ignore
rpm_install() {
cat <<EOF
This option has been deprecated.
To install the LSC software on your Fedora or RedHat system,
follow the instructions at the appropriate URL:
http://www.lsc-group.phys.uwm.edu/daswg/download/repositories.html#fedora
http://www.lsc-group.phys.uwm.edu/daswg/download/repositories.html#redhat
EOF
return 0
}
#/ignore


### Instructions for building from .TAR distributions
#ignore
tar_install() {
#/ignore
##section Build from .tar distribuion
##
## These instructions are supposed to be 'failsafe' ... i.e., they are
## supposed to work regardless of your operating system, user privilages, etc.
##
## The software is installed in the directory "LSCSOFT_LOCATION".
## If this variable is not set, it will be installed in "$HOME/opt/lscsoft"
## by default. To install in some other location, set "LSCSOFT_LOCATION"
## to that location.
##
## The build will take place in the directory "LSCSOFT_TMPDIR".
## If this variable is not set, the directory "/tmp/lscsoft-install" will be
## used.  You must have write access to this directory.  Warning: any contents
## in this directory will be desroyed.
##
## The commands listed below are appropriate for a Bourne-shell (e.g., bash);
## they will need to be modified appropriately for C-shells (e.g., tcsh).

#verbatim
LSCSOFT_PREFIX=/opt/lscsoft
LSCSOFT_TMPDIR=/tmp/lscsoft-install # warning: contents will be destroyed
#/verbatim
#ignore
test -d ${LSCSOFT_TMPDIR} && rm -rf ${LSCSOFT_TMPDIR}
#/ignore

## This is where to get sources:
#verbatim
LSCSOFT_SRCURL=http://www.lsc-group.phys.uwm.edu/daswg/download/software/source
#/verbatim

# setup directories
#verbatim
mkdir -p $LSCSOFT_PREFIX || fail
mkdir -p $LSCSOFT_TMPDIR || fail
#/verbatim
#ignore
mkdir -p $LSCSOFT_PREFIX/uninstall || fail
#/ignore

# get required fftw3, frame, gsl, and metaio
# you can use "lynx -dump" or "wget -O-" instead of "curl"
#verbatim
curl $LSCSOFT_SRCURL/fftw-3.2.1.tar.gz > $LSCSOFT_TMPDIR/fftw-3.2.1.tar.gz || fail
curl $LSCSOFT_SRCURL/gsl-1.12.tar.gz > $LSCSOFT_TMPDIR/gsl-1.12.tar.gz || fail
curl $LSCSOFT_SRCURL/libframe-8.04-2.tar.gz > $LSCSOFT_TMPDIR/libframe-8.04-2.tar.gz || fail
curl $LSCSOFT_SRCURL/metaio-8.2.tar.gz > $LSCSOFT_TMPDIR/metaio-8.2.tar.gz || fail
curl $LSCSOFT_SRCURL/glue-1.18.tar.gz > $LSCSOFT_TMPDIR/glue-1.18.tar.gz || fail
curl $LSCSOFT_SRCURL/lscsoft-user-env-1.13.tar.gz > $LSCSOFT_TMPDIR/lscsoft-user-env-1.13.tar.gz || fail
#/verbatim

# unpack these archives in "LSCSOFT_PREFIX/src"
#verbatim
cd $LSCSOFT_TMPDIR || fail
tar -zxvf $LSCSOFT_TMPDIR/fftw-3.2.1.tar.gz || fail
tar -zxvf $LSCSOFT_TMPDIR/gsl-1.12.tar.gz || fail
tar -zxvf $LSCSOFT_TMPDIR/libframe-8.04-2.tar.gz || fail
tar -zxvf $LSCSOFT_TMPDIR/metaio-8.2.tar.gz || fail
tar -zxvf $LSCSOFT_TMPDIR/glue-1.18.tar.gz || fail
tar -zxvf $LSCSOFT_TMPDIR/lscsoft-user-env-1.13.tar.gz || fail
#/verbatim

# build and install fftw3
#verbatim
cd $LSCSOFT_TMPDIR/fftw-3.2.1 || fail
./configure --prefix=$LSCSOFT_PREFIX/non-lsc --enable-shared --enable-float --disable-fortran || fail
make  # note: ignore fail... the build fails on MacOSX, but not seriously
make install # note: ignore fail
#/verbatim
#ignore
capture_uninstall $LSCSOFT_PREFIX/uninstall/uninstall-fftw3f.sh
#/ignore
#verbatim
make distclean || fail
./configure --prefix=$LSCSOFT_PREFIX/non-lsc --enable-shared --disable-fortran || fail
make # note: ignore fail
make install # note: ignore fail
#/verbatim
#ignore
capture_uninstall $LSCSOFT_PREFIX/uninstall/uninstall-fftw3.sh
#/ignore

# build and install gsl
#verbatim
cd $LSCSOFT_TMPDIR/gsl-1.12 || fail
./configure --prefix=$LSCSOFT_PREFIX/non-lsc || fail
make || fail
make install || fail
#/verbatim
#ignore
capture_uninstall $LSCSOFT_PREFIX/uninstall/uninstall-gsl.sh
#/ignore

# build and install libframe
#verbatim
cd $LSCSOFT_TMPDIR/libframe-8.04 || fail
./configure --prefix=$LSCSOFT_PREFIX/libframe --disable-octave --disable-python --with-matlab=no || fail
make || fail
make install || fail
#/verbatim
#ignore
capture_uninstall $LSCSOFT_PREFIX/uninstall/uninstall-libframe.sh
#/ignore

# build and install libmetaio
#verbatim
cd $LSCSOFT_TMPDIR/metaio-8.2 || fail
./configure --prefix=$LSCSOFT_PREFIX/libmetaio || fail
make || fail
make install || fail
#/verbatim
#ignore
capture_uninstall $LSCSOFT_PREFIX/uninstall/uninstall-libmetaio.sh
#/ignore

# build and install Glue
#verbatim
cd $LSCSOFT_TMPDIR/glue-1.18 || fail
python setup.py install --prefix=$LSCSOFT_PREFIX/glue || fail
#/verbatim

# build and install the user environment scripts
#verbatim
cd $LSCSOFT_TMPDIR/lscsoft-user-env-1.13 || fail
./configure --prefix=$LSCSOFT_PREFIX || fail
make || fail
make install || fail
#/verbatim
#ignore
capture_uninstall $LSCSOFT_PREFIX/uninstall/uninstall-lscsoft-user-env.sh
#/ignore

### Write an overall uninstall file
#ignore
cat > $LSCSOFT_PREFIX/uninstall/uninstall-all.sh <<EOF
#!/bin/sh
test -f $LSCSOFT_PREFIX/uninstall/uninstall-fftw3f.sh && /bin/sh $LSCSOFT_PREFIX/uninstall/uninstall-fftw3f.sh
test -f $LSCSOFT_PREFIX/uninstall/uninstall-fftw3.sh && /bin/sh $LSCSOFT_PREFIX/uninstall/uninstall-fftw3.sh
test -f $LSCSOFT_PREFIX/uninstall/uninstall-gsl.sh && /bin/sh $LSCSOFT_PREFIX/uninstall/uninstall-gsl.sh
test -f $LSCSOFT_PREFIX/uninstall/uninstall-libframe.sh && /bin/sh $LSCSOFT_PREFIX/uninstall/uninstall-libframe.sh
test -f $LSCSOFT_PREFIX/uninstall/uninstall-libmetaio.sh && /bin/sh $LSCSOFT_PREFIX/uninstall/uninstall-libmetaio.sh
test -f $LSCSOFT_PREFIX/uninstall/uninstall-lscsoft-user-env.sh && /bin/sh $LSCSOFT_PREFIX/uninstall/uninstall-lscsoft-user-env.sh
rm -rf $LSCSOFT_PREFIX/glue
rm -f $LSCSOFT_PREFIX/uninstall/uninstall-all.sh
EOF
chmod +x $LSCSOFT_PREFIX/uninstall/uninstall-all.sh
#/ignore

### For illustration purposes only...
#ignore
if false; then ###omit
#/ignore
## To setup your environment to use the software that has been installed
## please add the following to your .profile if you use a bourne shell
## (e.g. bash):
#verbatim
LSCSOFT_LOCATION=${HOME}/opt/lscsoft # change this as appropriate
export LSCSOFT_LOCATION
if [ -f ${LSCSOFT_LOCATION}/lscsoft-user-env.sh ] ; then
  . ${LSCSOFT_LOCATION}/lscsoft-user-env.sh
fi
#/verbatim
## If you are using a C shell (e.g., tcsh), instead add these lines to
## your .login:
#verbatim
#setenv LSCSOFT_LOCATION ${HOME}/opt/lscsoft # change this as appropriate
#if ( -r ${LSCSOFT_LOCATION}/lscsoft-user-env.csh ) then
#	source ${LSCSOFT_LOCATION}/lscsoft-user-env.csh
#endif
#/verbatim
#ignore
fi ###/omit
#/ignore
# cleanup (optional)
#verbatim
rm -rf $LSCSOFT_TMPDIR
#/verbatim
#ignore
print_tar_environment_setup_message
return 0
}
#/ignore


### End of functions
### The script starts here
### Ignore the rest of this file in documentation
#ignore

parse_args $*

### do the chosen installation
case $mode in
  none) print_error "you must supply a mode for obtaining software $helpmsg";;
  rpm) is_root && rpm_install || print_error "must be root to install rpms";;
  deb) is_root && deb_install || print_error "must be root to install debian packages";;
  tar) tar_install;;
  *) print_error "unknown mode for obtaining software";;
esac
exit

#/ignore
