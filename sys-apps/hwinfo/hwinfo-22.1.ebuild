# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib rpm toolchain-funcs

DESCRIPTION="Hardware detection tool used in SuSE Linux"
HOMEPAGE="https://github.com/openSUSE/hwinfo/"
# The SRC_URI is a source rpm package because the github repo misses some features and there
# are way too many tags to go trough until we hit the appropriate one
SRC_URI="https://download.opensuse.org/source/tumbleweed/repo/oss/src/./hwinfo-22.1-2.1.src.rpm -> hwinfo-22.1.rpm"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	amd64? ( dev-libs/libx86emu )
	x86? ( dev-libs/libx86emu )"
DEPEND="${RDEPEND}
	sys-devel/flex
	>=sys-kernel/linux-headers-2.6.17"

src_unpack() {
	rpm_src_unpack ${A}
	unpack ${WORKDIR}/${P}.tar.xz
}

# Oh god, so here is the problem with this application. For some reason when the makefile is compiled
# it is normal to get errors, but these errors are automatically resolved, this pisses off emake
# however, so to fix this we're using raw make. After that you might notice that we don't use MAKEOPTS
# and that's because when compiling here it also fails with parallel(don't know why). That's not a problem at~
# least because the application is small in C translation units and given how long an O(n^2) loop in the Makefile~
# takes that resolves errors and inconsistencies(6.5 minutes on a machine with an AMD Ryzen 9 3900x and 32gb of ram)
# It honestly wouldn't make a difference in the long run. Just to note that as of version 22.1 there is a pull request
# to the github repo of this application that resolves the O(n^2) loop problem and from my test compilation compiles in 55 seconds
# so at least this may be resolved in the next release.
#
# That's not all, when the first make fails we might not be getting an actual error, so
# we have a final check, which calls make and tests if the hwinfo executable exists. Why call make again?
# For some reason the executable didn't get outputted the first time on a random basis, but calling it again
# almost always fixes the problem, and if this fails then we definitely have an error so we die
# I will keep this under an if statement so that future versions don't do this stupidity
fallback_compilation_strategy() {
	make CC="$1" RPM_OPT_FLAGS="$2" || (make; test -f "${WORKDIR}/hwinfo") || die
}

src_compile() {
	tc-export AR
	cc=$(tc-getCC)
	make CC="${cc}" RPM_OPT_FLAGS="${CFLAGS}" ${MAKEOPTS} || fallback_compilation_strategy "${cc}" "${CFLAGS}"
}

src_install() {
	emake DESTDIR="${ED}" LIBDIR="/usr/$(get_libdir)" install
	keepdir /var/lib/hardware/udi

	dodoc changelog README*
	docinto examples
	dodoc doc/example*.c
	doman doc/*.{1,8}
}
