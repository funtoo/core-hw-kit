# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit linux-mod

DESCRIPTION="Realtek RTL8821CE Driver"
HOMEPAGE="https://github.com/tomaspinho/rtl8821ce"
SRC_URI="https://github.com/tomaspinho/rtl8821ce/archive/dce62b9bbb7c76339b514153fcebb3a19bafdcc7.tar.gz -> rtl8821ce-20220330.tar.gz"

LICENSE="GPL-2"
KEYWORDS="*"

DEPEND="virtual/linux-sources"

MODULE_NAMES="8821ce(net/wireless)"
BUILD_TARGETS="all"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}"/rtl8821ce-* "${S}"
}