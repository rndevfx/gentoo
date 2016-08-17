# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4} )

inherit eutils python-any-r1

DESCRIPTION="SPICE server"
HOMEPAGE="http://spice-space.org/"
SRC_URI="http://spice-space.org/download/releases/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libressl lz4 sasl smartcard static-libs gstreamer mjpeg vpx x264"

# the libspice-server only uses the headers of libcacard
RDEPEND="
	>=dev-libs/glib-2.22:2[static-libs(+)?]
	>=media-libs/celt-0.5.1.1:0.5.1[static-libs(+)?]
	media-libs/opus[static-libs(+)?]
	sys-libs/zlib[static-libs(+)?]
	virtual/jpeg:0=[static-libs(+)?]
	>=x11-libs/pixman-0.17.7[static-libs(+)?]
	!libressl? ( dev-libs/openssl:0[static-libs(+)?] )
	libressl? ( dev-libs/libressl[static-libs(+)?] )
	lz4? ( app-arch/lz4 )
	smartcard? ( >=app-emulation/libcacard-0.1.2 )
	sasl? ( dev-libs/cyrus-sasl[static-libs(+)?] )
	gstreamer? (
		media-libs/gstreamer:1.0
		mjpeg? ( media-plugins/gst-plugins-libav:1.0 )
		vpx? ( media-plugins/gst-plugins-vpx:1.0 )
		x264? ( media-plugins/gst-plugins-x264:1.0 ) )"

DEPEND="
	~app-emulation/spice-protocol-0.12.12
	virtual/pkgconfig
	$(python_gen_any_dep '
		>=dev-python/pyparsing-1.5.6-r2[${PYTHON_USEDEP}]
		dev-python/six[${PYTHON_USEDEP}]
	')
	smartcard? ( app-emulation/qemu[smartcard] )
	${RDEPEND}"

REQUIRED_USE="gstreamer? ( || ( mjpeg vpx x264 ) )"

# Prevent sandbox violations, bug #586560
# https://bugzilla.gnome.org/show_bug.cgi?id=581836
addpredict /dev

python_check_deps() {
	has_version ">=dev-python/pyparsing-1.5.6-r2[${PYTHON_USEDEP}]"
	has_version "dev-python/six[${PYTHON_USEDEP}]"
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && python-any-r1_pkg_setup
}

# maintainer notes:
# * opengl support is currently broken
src_configure() {
	local myconf="
		$(use_enable static-libs static)
		$(use_enable lz4)
		$(use_with sasl)
		$(use_enable smartcard)
		--enable-celt051
		--disable-gui
		"
	if use gstreamer; then
		myconf+="--enable-gstreamer=1.0"
	else
		myconf+="--enable-gstreamer=no"
	fi

	econf ${myconf}
}

src_install() {
	default
	use static-libs || prune_libtool_files
}
