# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{9..12} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1 udev

DESCRIPTION="Cross-platform tool and drivers for liquid coolers and other devices"
HOMEPAGE="https://github.com/liquidctl/liquidctl"
LICENSE="GPL-3+"
SLOT="0"

if [[ "${PV}" == "9999" ]]; then
        inherit git-r3

        EGIT_REPO_URI="https://github.com/liquidctl/liquidctl.git"
else
        SRC_URI="https://github.com/liquidctl/liquidctl/releases/download/v${PV}/${P}.tar.gz"
        KEYWORDS="~amd64"
fi

RDEPEND="
        dev-python/colorlog[${PYTHON_USEDEP}]
        dev-python/crcmod[${PYTHON_USEDEP}]
        dev-python/docopt[${PYTHON_USEDEP}]
        dev-python/hidapi[${PYTHON_USEDEP}]
        dev-python/pillow[${PYTHON_USEDEP}]
        dev-python/pyusb[${PYTHON_USEDEP}]
        sys-apps/i2c-tools[${PYTHON_USEDEP},python]
"

BDEPEND="
        dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

# This is a merged PR, remove it on bump
# PATCHES=( "${FILESDIR}/709.patch" )

distutils_enable_tests pytest

src_test() {
        # Without this variable, it attempts to write to /var/run and fails
        XDG_RUNTIME_DIR="${T}/xdg" distutils-r1_src_test || die
}

python_install_all() {
        distutils-r1_python_install_all

        dodoc docs/*.md
        dodoc -r docs/linux/

        udev_dorules extra/linux/71-liquidctl.rules
}

pkg_postinst() {
        udev_reload
}

pkg_postrm() {
        udev_reload
}

