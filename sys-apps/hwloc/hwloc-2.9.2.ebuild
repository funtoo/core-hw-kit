# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools bash-completion-r1 cuda desktop flag-o-matic toolchain-funcs

DESCRIPTION="Displays the hardware topology in convenient formats"
HOMEPAGE="https://www.open-mpi.org/projects/hwloc/"
SRC_URI="https://github.com/open-mpi/hwloc/tarball/8e29bc935cdc6af7f9be348fc0da6a797bafe730 -> hwloc-2.9.2-8e29bc9.tar.gz"

LICENSE="BSD"
SLOT="0/15"
KEYWORDS="*"
IUSE="cairo +cpuid cuda debug nvml +pci static-libs svg udev xml X video_cards_nvidia"

# opencl: opencl support dropped with x11-drivers/ati-drivers being removed (bug #582406).
#         anyone with hardware is welcome to step up and help test to get it re-added.
# video-cards_nvidia: libXext/libX11 deps are only here, see HWLOC_GL_REQUIRES usage in config/hwloc.m4
RDEPEND=">=sys-libs/ncurses-5.9-r3:=
	cairo? ( >=x11-libs/cairo-1.12.14-r4[X?,svg(+)?] )
	cuda? ( >=dev-util/nvidia-cuda-toolkit-6.5.19-r1:= )
	nvml? ( x11-drivers/nvidia-drivers )
	pci? (
		>=sys-apps/pciutils-3.3.0-r2
		>=x11-libs/libpciaccess-0.13.1-r1
	)
	udev? ( virtual/libudev:= )
	xml? ( >=dev-libs/libxml2-2.9.1-r4 )
	video_cards_nvidia? (
		x11-drivers/nvidia-drivers[static-libs]
		x11-libs/libXext
		x11-libs/libX11
	)"
DEPEND="${RDEPEND}"
BDEPEND=">=sys-devel/autoconf-2.69-r4
	virtual/pkgconfig"

DOCS=( AUTHORS NEWS README VERSION )

src_unpack() {
	unpack "${A}"
	mv "${WORKDIR}"/*-${PN}-* "${S}"
}

src_prepare() {
	default

	# NVIDIA OpenGL patch
	sed -i "s/\[-lXext\]/\[-lXext -lX11\]/g" "${S}"/config/hwloc.m4

	eautoreconf
}

src_configure() {
	# bug #393467
	export HWLOC_PKG_CONFIG="$(tc-getPKG_CONFIG)"

	if use video_cards_nvidia ; then
		addpredict /dev/nvidiactl
	fi

	if use cuda ; then
		append-cflags "-I${ESYSROOT}/opt/cuda/include"
		append-cppflags "-I${ESYSROOT}/opt/cuda/include"

		local -x LDFLAGS="${LDFLAGS}"
		append-ldflags "-L${ESYSROOT}/opt/cuda/$(get_libdir)"
	fi

	local myconf=(
		--disable-opencl
		--disable-netloc
		--disable-plugin-ltdl
		--enable-plugins
		--enable-shared
		$(use_enable cuda)
		$(use_enable video_cards_nvidia gl)
		$(use_enable cairo)
		$(use_enable cpuid)
		$(use_enable debug)
		$(use_enable udev libudev)
		$(use_enable nvml)
		$(use_enable pci)
		$(use_enable static-libs static)
		$(use_enable xml libxml2)
		$(use_with X x)
	)

	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

src_install() {
	default

	mv "${ED}"/usr/share/bash-completion/completions/hwloc{,-annotate} || die
	bashcomp_alias hwloc-annotate \
		hwloc-{diff,ps,compress-dir,gather-cpuid,distrib,info,bind,patch,calc,ls,gather-topology}
	bashcomp_alias hwloc-annotate lstopo{,-no-graphics}

	find "${ED}" -name '*.la' -delete || die
	doicon "${S}"/contrib/android/assets/lstopo.png
}