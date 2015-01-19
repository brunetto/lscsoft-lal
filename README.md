

```
# https://www.lsc-group.phys.uwm.edu/daswg/docs/howto/lal-install.html
# https://www.lsc-group.phys.uwm.edu/daswg/docs/howto/lscsoft-install.html

apt-get update \
&& apt-get install build-essential wget gawk gfortran libarchive13 python \
python-dev automake autoconf libtool devscripts git libxslt-dev libxml2-dev

wget http://zlib.net/fossils/zlib-1.2.3.5.tar.gz \
&& tar -xvf zlib-1.2.3.5.tar.gz \
&& cd zlib-1.2.3.5 \
&& ./configure \
&& make \
&& make install \
&& cd .. \
&& rm -r zlib-1.2.3.5* 

export LSCSOFT_LOCATION=/opt/lscsoft \
&& export LSCSOFT_PREFIX=/opt/lscsoft \
&& export LSCSOFT_TMPDIR=/opt/lscsoft/sources/ \
&& export LSCSOFT_SRCURL=http://www.lsc-group.phys.uwm.edu/daswg/download/software/source 

mkdir -p $LSCSOFT_PREFIX && mkdir -p $LSCSOFT_TMPDIR

wget -O- $LSCSOFT_SRCURL/pkg-config-0.23.tar.gz > $LSCSOFT_TMPDIR/pkg-config-0.23.tar.gz \
&& wget -O- $LSCSOFT_SRCURL/fftw-3.2.1.tar.gz > $LSCSOFT_TMPDIR/fftw-3.2.1.tar.gz \
<!-- && wget -O- $LSCSOFT_SRCURL/gsl-1.12.tar.gz > $LSCSOFT_TMPDIR/gsl-1.12.tar.gz \ -->
&& wget -O- http://mirror2.mirror.garr.it/mirrors/gnuftp/gnu/gsl/gsl-1.16.tar.gz > $LSCSOFT_TMPDIR/gsl-1.16.tar.gz \
&& wget -O- $LSCSOFT_SRCURL/libframe-8.04-2.tar.gz > $LSCSOFT_TMPDIR/libframe-8.04-2.tar.gz \
&& wget -O- $LSCSOFT_SRCURL/metaio-8.2.tar.gz > $LSCSOFT_TMPDIR/metaio-8.2.tar.gz \
&& wget -O- $LSCSOFT_SRCURL/glue-1.18.tar.gz > $LSCSOFT_TMPDIR/glue-1.18.tar.gz \
&& wget -O- $LSCSOFT_SRCURL/lscsoft-user-env-1.13.tar.gz > $LSCSOFT_TMPDIR/lscsoft-user-env-1.13.tar.gz 

cd $LSCSOFT_TMPDIR \
&& tar -zxvf $LSCSOFT_TMPDIR/pkg-config-0.23.tar.gz \
&& tar -zxvf $LSCSOFT_TMPDIR/fftw-3.2.1.tar.gz \
<!-- && tar -zxvf $LSCSOFT_TMPDIR/gsl-1.12.tar.gz \ -->
&& tar -zxvf $LSCSOFT_TMPDIR/gsl-1.16.tar.gz \
&& tar -zxvf $LSCSOFT_TMPDIR/libframe-8.04-2.tar.gz \
&& tar -zxvf $LSCSOFT_TMPDIR/metaio-8.2.tar.gz \
&& tar -zxvf $LSCSOFT_TMPDIR/glue-1.18.tar.gz \
&& tar -zxvf $LSCSOFT_TMPDIR/lscsoft-user-env-1.13.tar.gz


<!-- wget https://www.lsc-group.phys.uwm.edu/daswg/docs/howto/lscsoft-install-x.sh \ -->
<!-- wget https://www.dropbox.com/s/tk1xsuxyl0tjra8/lscsoft-install-x.sh \ # lscsoft-install-x.sh version without pkg-config -->
<!-- && bash lscsoft-install-x.sh  --verbose --from-tar=/opt/lscsoft -->



<!-- # build and install pkg-config
cd $LSCSOFT_TMPDIR/pkg-config-0.23 
./configure --prefix=$LSCSOFT_PREFIX/non-lsc 
make 
make install -->


cd $LSCSOFT_TMPDIR/fftw-3.2.1 
./configure --prefix=$LSCSOFT_PREFIX/non-lsc --enable-shared --enable-float --disable-fortran \
&& make && make install && make distclean \
&& ./configure --prefix=$LSCSOFT_PREFIX/non-lsc --enable-shared --disable-fortran \
&& make && make install 
<!-- cd $LSCSOFT_TMPDIR/gsl-1.12  -->
cd $LSCSOFT_TMPDIR/gsl-1.16
./configure --prefix=$LSCSOFT_PREFIX/non-lsc && make && make install 
cd $LSCSOFT_TMPDIR/libframe-8.04
./configure --prefix=$LSCSOFT_PREFIX/libframe --disable-octave --disable-python --with-matlab=no \
&& make && make install 
cd $LSCSOFT_TMPDIR/metaio-8.2 && ./configure --prefix=$LSCSOFT_PREFIX/libmetaio && make && make install 
cd $LSCSOFT_TMPDIR/glue-1.18 && python setup.py install --prefix=$LSCSOFT_PREFIX/glue 
cd $LSCSOFT_TMPDIR/lscsoft-user-env-1.13 && ./configure --prefix=$LSCSOFT_PREFIX && make && make install 
cd /
<!-- rm -rf $LSCSOFT_TMPDIR -->

echo "export PKG_CONFIG=/usr/bin/pkg-config" >> .bashrc \
&& echo "LSCSOFT_LOCATION=/opt/lscsoft" >> .bashrc \
&& echo "export LSCSOFT_LOCATION" >> .bashrc \
&& echo ". $LSCSOFT_LOCATION/lscsoft-user-env.sh" >> .bashrc \
&& echo "LSCSOFT_SRCDIR=/src/lscsoft/" >> .bashrc \
&& echo "LSCSOFT_ROOTDIR=/" >> .bashrc \
&& echo "LAL_PREFIX=/opt/lscsoft/lal" >> .bashrc \
&& . .bashrc


apt-get install pkg-config

mkdir -p $LSCSOFT_SRCDIR \
&& cd $LSCSOFT_SRCDIR \
&& git clone git://ligo-vcs.phys.uwm.edu/lalsuite.git # read only git repo for public users 

cd $LSCSOFT_SRCDIR/lalsuite/lal \
&& ./00boot \ 
&& ./configure --prefix=$LAL_PREFIX
make
make install

cd /

echo ". /opt/lscsoft/lal/etc/lal-user-env.sh" >> .bashrc 
. .bashrc

mkdir -p ${LSCSOFT_ROOTDIR}/etc
echo "export LSCSOFT_LOCATION=${LSCSOFT_ROOTDIR}/opt/lscsoft" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "# setup LAL for development:  " >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "export LAL_LOCATION=\$LSCSOFT_LOCATION/lal" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "if [ -f "\$LAL_LOCATION/etc/lal-user-env.sh" ]; then" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "  source \$LAL_LOCATION/etc/lal-user-env.sh" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "fi" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
source ${LSCSOFT_ROOTDIR}/etc/lscsoftrc

lal-version

LALFRAME_PREFIX=/opt/lscsoft/lalframe
cd ${LSCSOFT_SRCDIR}/lalsuite/lalframe
./00boot
./configure --prefix=${LALFRAME_PREFIX}
make
make install

echo ". /opt/lscsoft/lalframe/etc/lalframe-user-env.sh" >> /.bashrc

echo "# setup LALFrame for development:  " >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "export LALFRAME_LOCATION=\$LSCSOFT_LOCATION/lalframe" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "if [ -f "\$LALFRAME_LOCATION/etc/lalframe-user-env.sh" ]; then" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "  source \$LALFRAME_LOCATION/etc/lalframe-user-env.sh" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "fi" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc

source ${LSCSOFT_ROOTDIR}/etc/lscsoftrc



LALMETAIO_PREFIX=/opt/lscsoft/lalmetaio

cd ${LSCSOFT_SRCDIR}/lalsuite/lalmetaio
./00boot
./configure --prefix=${LALMETAIO_PREFIX}
make
make install

echo " . /opt/lscsoft/lalmetaio/etc/lalmetaio-user-env.sh" >> /.bashrc

echo "# setup LALMetaIO for development:  " >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "export LALMETAIO_LOCATION=\$LSCSOFT_LOCATION/lalmetaio" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "if [ -f "\$LALMETAIO_LOCATION/etc/lalmetaio-user-env.sh" ]; then" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "  source \$LALMETAIO_LOCATION/etc/lalmetaio-user-env.sh" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "fi" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc

source ${LSCSOFT_ROOTDIR}/etc/lscsoftrc

LALXML_PREFIX=/opt/lscsoft/lalxml
cd ${LSCSOFT_SRCDIR}/lalsuite/lalxml
./00boot
./configure --prefix=${LALXML_PREFIX}
make && make install
echo " . /opt/lscsoft/lalmetaio/etc/lalxml-user-env.sh" >> /.bashrc
echo "# setup LALXML for development:  " >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "export LALXML_LOCATION=\$LSCSOFT_LOCATION/lalxml" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "if [ -f "\$LALXML_LOCATION/etc/lalxml-user-env.sh" ]; then" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "  source \$LALXML_LOCATION/etc/lalxml-user-env.sh" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc
echo "fi" >> ${LSCSOFT_ROOTDIR}/etc/lscsoftrc

source ${LSCSOFT_ROOTDIR}/etc/lscsoftrc

















```

* lalxml non si installa perche': 

checking for LIBXML2... yes
checking for xmlInitParser in -lxml2... no
configure: WARNING: cannot find the xml2 library


* lalpulsar nemmeno perche' ha bisogno di lalxml


## Installazione

* https://raw.githubusercontent.com/waisbrot/lalsuite-docker/master/Prereqs/Dockerfile
* https://raw.githubusercontent.com/waisbrot/lalsuite-docker/master/Dockerfile
* https://www.lsc-group.phys.uwm.edu/daswg/projects/lalsuite.html
* https://www.lsc-group.phys.uwm.edu/daswg/docs/howto/lal-install.html
* https://github.com/gwpy

* http://www2.physics.umd.edu/~pshawhan/courses/CGWA/
* http://www2.physics.umd.edu/~pshawhan/courses/CGWA/ShawhanLecture1.pdf
* http://www2.physics.umd.edu/~pshawhan/courses/CGWA/ShawhanLecture2.pdf
* http://www2.physics.umd.edu/~pshawhan/courses/CGWA/ShawhanLecture3.pdf
* http://www2.physics.umd.edu/~pshawhan/courses/CGWA/ShawhanLecture4.pdf
* http://www2.physics.umd.edu/~pshawhan/courses/CGWA/ShawhanLecture5.pdf

* http://www.stellarcollapse.org/

* http://www.phys.lsu.edu/faculty/gonzalez/Teaching/GWseminar/FinalExam/

* https://www.lsc-group.phys.uwm.edu/daswg/projects/lal/nightly/docs/html/group__pkg__inspiral.html

Nice figure here:

* http://www.gw-indigo.org/tiki-download_wiki_attachment.php?attId=22 

* http://www.gw-indigo.org/tiki-index.php?page=The%20Data%20Set

* https://docs.google.com/viewer?url=http%3A%2F%2Fwww.dam.brown.edu%2Fpeople%2Fsfield%2FCornell_11_20_2013.pdf

```
FROM ringo/scientific:6.5
MAINTAINER Nathaniel Waisbrot <code@waisbrot.net>

RUN yum -y groupinstall "Development Tools" "Development Libraries"
RUN yum install -y zlib-devel fftw-devel libxml2-devel glib2-devel

# GSL (latest version is not in RPM)
RUN mkdir -p /opt/gsl/src \
 && cd /opt/gsl/src \
 && wget http://mirrors.ibiblio.org/gnu/ftp/gnu/gsl/gsl-1.16.tar.gz -O - \
    | tar xzf - \
 && cd /opt/gsl/src/gsl-1.16 \
 && ./configure \
 && make \
 && make install

# FrameL
RUN mkdir -p /opt/framel/src \
 && cd /opt/framel/src/ \
 && wget http://lappweb.in2p3.fr/virgo/FrameL/libframe-8.21.tar.gz -O - \
    | tar xzf - \
 && cd /opt/framel/src/libframe-8.21 \
 && ./configure \
 && make \
 && make install

# MetaIO
RUN mkdir -p /opt/metaio/src \
 && cd /opt/metaio/src \
 && wget https://www.lsc-group.phys.uwm.edu/daswg/download/software/source/metaio-8.3.0.tar.gz -O - \
    | tar xzf - \
 && cd /opt/metaio/src/metaio-8.3.0 \
 && ./configure \
 && make \
 && make install

ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/lib64/pkgconfig
ENV LD_LIBRARY_PATH=/usr/local/lib

CMD ["/bin/bash"]


--------------------


FROM waisbrot/lalsuite-prereqs-docker
MAINTAINER Nathaniel Waisbrot <code@waisbrot.net>

ENV LSCSOFT_ROOTDIR= \
    LSCSOFT_SRCDIR=/opt/src/lscsoft

# configure Git
RUN git config --global user.name "Anonymous" \
 && git config --global user.email anonymous@example.com


WORKDIR $LSCSOFT_SRCDIR
RUN git clone git://ligo-vcs.phys.uwm.edu/lalsuite.git .
RUN ./00boot && ./configure && make test && make && make install
```







