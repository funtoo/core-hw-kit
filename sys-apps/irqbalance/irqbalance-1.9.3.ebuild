# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools systemd linux-info

DESCRIPTION="The irqbalance source tree - The new official site for irqbalance"
HOMEPAGE="https://github.com/Irqbalance/irqbalance"
SRC_URI="https://github.com/Irqbalance/irqbalance/tarball/5635a2eabb7fe20912807a28d8b6793831ef9936 -> irqbalance-1.9.3-5635a2e.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="caps +numa systemd selinux tui"
# Hangs
RESTRICT="test"

DEPEND="
	dev-libs/glib:2
	dev-libs/libnl:3
	caps? ( sys-libs/libcap-ng )
	numa? ( sys-process/numactl )
	systemd? ( sys-apps/systemd:= )
	tui? ( sys-libs/ncurses:= )
"
BDEPEND="
	virtual/pkgconfig
"
RDEPEND="
	${DEPEND}
	selinux? ( sec-policy/selinux-irqbalance )
"

pkg_setup() {
	CONFIG_CHECK="~PCI_MSI"
	linux-info_pkg_setup
}

post_src_unpack() {
	if [ ! -d "${S}" ]; then
		mv Irqbalance-irqbalance* "${S}" || die
	fi
}

src_prepare() {
	# Follow systemd policies
	# https://wiki.gentoo.org/wiki/Project:Systemd/Ebuild_policy
	if use systemd; then
		sed \
			-e 's/ $IRQBALANCE_ARGS//' \
			-e '/EnvironmentFile/d' \
			-i misc/irqbalance.service || die
	fi

	default
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		$(use_with caps libcap-ng)
		$(use_enable numa)
		$(use_with systemd)
		$(use_with tui irqbalance-ui)
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	newinitd "${FILESDIR}"/irqbalance.init irqbalance
	newconfd "${FILESDIR}"/irqbalance.confd irqbalance
	use systemd && systemd_dounit misc/irqbalance.service
}