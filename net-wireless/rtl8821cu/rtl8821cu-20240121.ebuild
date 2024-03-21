# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit linux-mod

DESCRIPTION="Linux Driver for USB WiFi Adapters that are based on the RTL8811CU, RTL8821CU, RTL8821CUH and RTL8731AU Chipsets"
HOMEPAGE="https://github.com/morrownr/8821cu-20210916"
SRC_URI="https://github.com/morrownr/8821cu-20210916/archive/5b39398e2de146edeb76716420f3288f508bea61.tar.gz -> rtl8821cu-20240121-5b39398e2de146edeb76716420f3288f508bea61.tar.gz"

LICENSE="GPL-2"
KEYWORDS="*"

DEPEND="virtual/linux-sources"

MODULE_NAMES="8821cu(net/wireless)"
BUILD_TARGETS="all"
S="${WORKDIR}/8821cu-20210916-5b39398e2de146edeb76716420f3288f508bea61"

src_prepare() {
	default

	# FL-8716: Use the latest kernel instead of the currently running one.
	get_version

	sed -i \
		-e "s|\$(shell uname -r)|${KV_FULL}|g" \
		Makefile
}