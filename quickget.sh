#!/usr/bin/env bash
# SC2317: Command appears to be unreachable. Check usage (or ignore if invoked indirectly).
#  - https://www.shellcheck.net/wiki/SC2317
#  - Disable globally because many functions are called indirectly
# shellcheck disable=SC2317
export LC_ALL=C

function cleanup() {
    if [ -n "$(jobs -p)" ]; then
        kill "$(jobs -p)" 2>/dev/null
    fi
}

function os_info() {
    local SIMPLE_NAME=""
    local INFO=""
    SIMPLE_NAME="${1}"
    case ${SIMPLE_NAME} in
        #name)            INFO="PrettyName|Credentials|Homepage|Info";;
        alma)             INFO="AlmaLinux|-|https://almalinux.org/|Community owned and governed, forever-free enterprise Linux distribution, focused on long-term stability, providing a robust production-grade platform. AlmaLinux OS is binary compatible with RHEL®.";;
        alpine)           INFO="Alpine Linux|-|https://alpinelinux.org/|Security-oriented, lightweight Linux distribution based on musl libc and busybox.";;
        android)          INFO="Android x86|-|https://www.android-x86.org/|Port Android Open Source Project to x86 platform.";;
        antix)            INFO="Antix|-|https://antixlinux.com/|Fast, lightweight and easy to install systemd-free linux live CD distribution based on Debian Stable for Intel-AMD x86 compatible systems.";;
        archcraft)        INFO="Archcraft|-|https://archcraft.io/|Yet another minimal Linux distribution, based on Arch Linux.";;
        archlinux)        INFO="Arch Linux|-|https://archlinux.org/|Lightweight and flexible Linux® distribution that tries to Keep It Simple.";;
        arcolinux)        INFO="Arco Linux|-|https://arcolinux.com/|Is all about becoming an expert in linux.";;
        artixlinux)       INFO="Artix Linux|-|https://artixlinux.org/|The Art of Linux. Simple. Fast. Systemd-free.";;
        athenaos)         INFO="Athena OS|-|https://athenaos.org/|Offer a different experience than the most used pentesting distributions by providing only tools that fit with the user needs and improving the access to hacking resources and learning materials.";;
        batocera)         INFO="Batocera|-|https://batocera.org/|Retro-gaming distribution with the aim of turning any computer/nano computer into a gaming console during a game or permanently.";;
        bazzite)          INFO="Bazzite|-|https://github.com/ublue-os/bazzite/|Container native gaming and a ready-to-game SteamOS like.";;
        biglinux)         INFO="BigLinux|-|https://www.biglinux.com.br/|Is the right choice if you want to have an easy and enriching experience with Linux. It has been perfected over more than 19 years, following our motto: 'In search of the perfect system'.";;
        blendos)          INFO="BlendOS|-|https://blendos.co/|A seamless blend of all Linux distributions. Allows you to have an immutable, atomic and declarative Arch Linux system, with application support from several Linux distributions & Android.";;
        bodhi)            INFO="Bodhi|-|https://www.bodhilinux.com/|Lightweight distribution featuring the fast & fully customizable Moksha Desktop.";;
        bunsenlabs)       INFO="BunsenLabs|-|https://www.bunsenlabs.org/|Light-weight and easily customizable Openbox desktop. The project is a community continuation of CrunchBang Linux.";;
        cachyos)          INFO="CachyOS|-|https://cachyos.org/|Designed to deliver lightning-fast speeds and stability, ensuring a smooth and enjoyable computing experience every time you use it.";;
        centos-stream)    INFO="CentOS Stream|-|https://www.centos.org/centos-stream/|Continuously delivered distro that tracks just ahead of Red Hat Enterprise Linux (RHEL) development, positioned as a midstream between Fedora Linux and RHEL.";;
        chimeralinux)     INFO="Chimera Linux|anon:chimera root:chimera|https://chimera-linux.org/|Modern, general-purpose non-GNU Linux distribution.";;
        crunchbang++)     INFO="Crunchbangplusplus|-|https://www.crunchbangplusplus.org/|The classic minimal crunchbang feel, now with debian 12 bookworm.";;
        debian)           INFO="Debian|-|https://www.debian.org/|Complete Free Operating System with perfect level of ease of use and stability.";;
        deepin)           INFO="Deepin|-|https://www.deepin.org/|Beautiful UI design, intimate human-computer interaction, and friendly community environment make you feel at home.";;
        devuan)           INFO="Devuan|-|https://www.devuan.org/|Fork of Debian without systemd that allows users to reclaim control over their system by avoiding unnecessary entanglements and ensuring Init Freedom.";;
        dragonflybsd)     INFO="DragonFlyBSD|-|https://www.dragonflybsd.org/|Provides an opportunity for the BSD base to grow in an entirely different direction from the one taken in the FreeBSD, NetBSD, and OpenBSD series.";;
        easyos)           INFO="EasyOS|-|https://easyos.org/|Experimental distribution designed from scratch to support containers.";;
        edubuntu)         INFO="Edubuntu|-|https://www.edubuntu.org/|Stable, secure and privacy concious option for schools.";;
        elementary)       INFO="elementary OS|-|https://elementary.io/|Thoughtful, capable, and ethical replacement for Windows and macOS.";;
        endeavouros)      INFO="EndeavourOS|-|https://endeavouros.com/|Provides an Arch experience without the hassle of installing it manually for both x86_64 and ARM systems.";;
        endless)          INFO="Endless OS|-|https://www.endlessos.org/os|Completely Free, User-Friendly Operating System Packed with Educational Tools, Games, and More.";;
        fedora)           INFO="Fedora|-|https://www.fedoraproject.org/|Innovative platform for hardware, clouds, and containers, built with love by you.";;
        freebsd)          INFO="FreeBSD|-|https://www.freebsd.org/|Operating system used to power modern servers, desktops, and embedded platforms.";;
        freedos)          INFO="FreeDOS|-|https://freedos.org/|DOS-compatible operating system that you can use to play classic DOS games, run legacy business software, or develop embedded systems.";;
        garuda)           INFO="Garuda Linux|-|https://garudalinux.org/|Feature rich and easy to use Linux distribution.";;
        gentoo)           INFO="Gentoo|-|https://www.gentoo.org/|Highly flexible, source-based Linux distribution.";;
        ghostbsd)         INFO="GhostBSD|-|https://www.ghostbsd.org/|Simple, elegant desktop BSD Operating System.";;
        gnomeos)          INFO="GNOME OS|-|https://os.gnome.org/|Alpha nightly bleeding edge distro of GNOME";;
        guix)             INFO="Guix|-|https://guix.gnu.org/|Distribution of the GNU operating system developed by the GNU Project—which respects the freedom of computer users.";;
        haiku)            INFO="Haiku|-|https://www.haiku-os.org/|Specifically targets personal computing. Inspired by the BeOS, Haiku is fast, simple to use, easy to learn and yet very powerful.";;
        holoiso)          INFO="HoloISO|-|https://github.com/HoloISO/holoiso|Bring the Steam Decks SteamOS Holo redistribution and provide a close-to-official SteamOS experience.";;
        kali)             INFO="Kali|-|https://www.kali.org/|The most advanced Penetration Testing Distribution.";;
        kdeneon)          INFO="KDE Neon|-|https://neon.kde.org/|Latest and greatest of KDE community software packaged on a rock-solid base.";;
        kolibrios)        INFO="KolibriOS|-|http://kolibrios.org/en/|Tiny yet incredibly powerful and fast operating system.";;
        kubuntu)          INFO="Kubuntu|-|https://kubuntu.org/|Free, complete, and open-source alternative to Microsoft Windows and Mac OS X which contains everything you need to work, play, or share.";;
        linuxlite)        INFO="Linux Lite|-|https://www.linuxliteos.com/|Your first simple, fast and free stop in the world of Linux.";;
        linuxmint)        INFO="Linux Mint|-|https://linuxmint.com/|Designed to work out of the box and comes fully equipped with the apps most people need.";;
        lmde)             INFO="Linux Mint Debian Edition|-|https://www.linuxmint.com/download_lmde.php|Aims to be as similar as possible to Linux Mint, but without using Ubuntu. The package base is provided by Debian instead.";;
        lubuntu)          INFO="Lubuntu|-|https://lubuntu.me/|Complete Operating System that ships the essential apps and services for daily use: office applications, PDF reader,  image editor, music and video players, etc. Using lightwave lxde/lxqt.";;
        mageia)           INFO="Mageia|-|https://www.mageia.org/|Stable, secure operating system for desktop & server.";;
        manjaro)          INFO="Manjaro|-|https://manjaro.org/|Versatile, free, and open-source Linux operating system designed with a strong focus on safeguarding user privacy and offering extensive control over hardware.";;
        mxlinux)          INFO="MX Linux|-|https://mxlinux.org/|Designed to combine elegant and efficient desktops with high stability and solid performance.";;
        netboot)          INFO="netboot.xyz|-|https://netboot.xyz/|Your favorite operating systems in one place.";;
        netbsd)           INFO="NetBSD|-|https://www.netbsd.org/|Free, fast, secure, and highly portable Unix-like Open Source operating system. It is available for a wide range of platforms, from large-scale servers and powerful desktop systems to handheld and embedded devices.";;
        nitrux)           INFO="Nitrux|-|https://nxos.org/|Powered by Debian, KDE Plasma and Frameworks, and AppImages.";;
        nixos)            INFO="NixOS|-|https://nixos.org/|Linux distribution based on Nix package manager, tool that takes a unique approach to package management and system configuration.";;
        nwg-shell)        INFO="nwg-shell|nwg:nwg|https://nwg-piotr.github.io/nwg-shell/|Arch Linux ISO with nwg-shell for sway and Hyprland";;
        macos)            INFO="macOS|-|https://www.apple.com/macos/|Work and play on your Mac are even more powerful. Elevate your presence on video calls. Access information in all-new ways. Boost gaming performance. And discover even more ways to personalize your Mac.";;
        openbsd)          INFO="OpenBSD|-|https://www.openbsd.org/|FREE, multi-platform 4.4BSD-based UNIX-like operating system. Our efforts emphasize portability, standardization, correctness, proactive security and integrated cryptography.";;
        openindiana)      INFO="OpenIndiana|-|https://www.openindiana.org/|Community supported illumos-based operating system.";;
        opensuse)         INFO="openSUSE|-|https://www.opensuse.org/|The makers choice for sysadmins, developers and desktop users.";;
        oraclelinux)      INFO="Oracle Linux|-|https://www.oracle.com/linux/|Linux with everything required to deploy, optimize, and manage applications on-premises, in the cloud, and at the edge.";;
        parrotsec)        INFO="Parrot Security|parrot:parrot|https://www.parrotsec.org/|Provides a huge arsenal of tools, utilities and libraries that IT and security professionals can use to test and assess the security of their assets in a reliable, compliant and reproducible way.";;
        peppermint)       INFO="PeppermintOS|-|https://peppermintos.com/|Provides a user with the opportunity to build the system that best fits their needs. While at the same time providing a functioning OS with minimum hassle out of the box.";;
        popos)            INFO="Pop!_OS|-|https://pop.system76.com/|Operating system for STEM and creative professionals who use their computer as a tool to discover and create.";;
        porteus)          INFO="Porteus|-|http://www.porteus.org/|Complete linux operating system that is optimized to run from CD, USB flash drive, hard drive, or other bootable storage media.";;
        primtux)          INFO="PrimTux|-|https://primtux.fr/|A complete and customizable GNU/Linux operating system intended for primary school students and suitable even for older hardware.";;
        pureos)           INFO="PureOS|-|https://www.pureos.net/|A fully free/libre and open source GNU/Linux operating system, endorsed by the Free Software Foundation.";;
        reactos)          INFO="ReactOS|-|https://reactos.org/|Imagine running your favorite Windows applications and drivers in an open-source environment you can trust.";;
        rebornos)         INFO="RebornOS|-|https://rebornos.org/|Aiming to make Arch Linux as user friendly as possible by providing interface solutions to things you normally have to do in a terminal.";;
        rockylinux)       INFO="Rocky Linux|-|https://rockylinux.org/|Open-source enterprise operating system designed to be 100% bug-for-bug compatible with Red Hat Enterprise Linux®.";;
        siduction)        INFO="Siduction|-|https://siduction.org/|Operating system based on the Linux kernel and the GNU project. In addition, there are applications and libraries from Debian.";;
        slackware)        INFO="Slackware|-|http://www.slackware.com/|Advanced Linux operating system, designed with the twin goals of ease of use and stability as top priorities.";;
        slax)             INFO="Slax|-|https://www.slax.org/|Compact, fast, and modern Linux operating system that combines sleek design with modular approach. With the ability to run directly from a USB flash drive without the need for installation, Slax is truly portable and fits easily in your pocket.";;
        slint)            INFO="Slint|-|https://slint.fr/|Slint is an easy-to-use, versatile, blind-friendly Linux distribution for 64-bit computers. Slint is based on Slackware and borrows tools from Salix. Maintainer: Didier Spaier.";;
        slitaz)           INFO="SliTaz|-|https://www.slitaz.org/en/|Simple, fast and low resource Linux OS for servers & desktops.";;
        solus)            INFO="Solus|-|https://getsol.us/|Designed for home computing. Every tweak enables us to deliver a cohesive computing experience.";;
        sparkylinux)      INFO="SparkyLinux|-|https://sparkylinux.org/|Fast, lightweight and fully customizable operating system which offers several versions for different use cases.";;
        spirallinux)      INFO="SpiralLinux|-|https://spirallinux.github.io/|Selection of Linux spins built from Debian GNU/Linux, with a focus on simplicity and out-of-the-box usability across all the major desktop environments.";;
        tails)            INFO="Tails|-|https://tails.net/|Portable operating system that protects against surveillance and censorship.";;
        tinycore)         INFO="Tiny Core Linux|-|http://www.tinycorelinux.net/|Highly modular based system with community build extensions.";;
        trisquel)         INFO="Trisquel-|https://trisquel.info/|Fully free operating system for home users, small enterprises and educational centers.";;
        truenas-core)     INFO="TrueNAS Core|-|https://www.truenas.com/truenas-core/|World’s most popular storage OS because it gives you the power to build your own professional-grade storage system to use in a variety of data-intensive applications without any software costs.";;
        truenas-scale)    INFO="TrueNAS Scale|-|https://www.truenas.com/truenas-scale/|Open Source Hyperconverged Infrastructure (HCI) solution. In addition to powerful scale-out storage capabilities, SCALE adds Linux Containers and VMs (KVM) so apps run closer to data.";;
        tuxedo-os)        INFO="Tuxedo OS|-|https://www.tuxedocomputers.com/en/|KDE Ubuntu LTS designed to go with their Linux hardware.";;
        ubuntu)           INFO="Ubuntu|-|https://ubuntu.com/|Complete desktop Linux operating system, freely available with both community and professional support.";;
        ubuntu-budgie)    INFO="Ubuntu Budgie|-|https://ubuntubudgie.org/|Community developed distribution, integrating the Budgie Desktop Environment with Ubuntu at its core.";;
        ubuntucinnamon)   INFO="Ubuntu Cinnamon|-|https://ubuntucinnamon.org/|Community-driven, featuring Linux Mint’s Cinnamon Desktop with Ubuntu at the core, packed fast and full of features, here is the most traditionally modern desktop you will ever love.";;
        ubuntukylin)      INFO="Ubuntu Kylin|-|https://ubuntukylin.com/|Universal desktop operating system for personal computers, laptops, and embedded devices. It is dedicated to bringing a smarter user experience to users all over the world.";;
        ubuntu-mate)      INFO="Ubuntu MATE|-|https://ubuntu-mate.org/|Stable, easy-to-use operating system with a configurable desktop environment. It is ideal for those who want the most out of their computers and prefer a traditional desktop metaphor. Using Mate desktop.";;
        ubuntu-server)    INFO="Ubuntu Server|-|https://ubuntu.com/server|Brings economic and technical scalability to your datacentre, public or private. Whether you want to deploy an OpenStack cloud, a Kubernetes cluster or a 50,000-node render farm, Ubuntu Server delivers the best value scale-out performance available.";;
        ubuntustudio)     INFO="Ubuntu Studio|-|https://ubuntustudio.org/|Comes preinstalled with a selection of the most common free multimedia applications available, and is configured for best performance for various purposes: Audio, Graphics, Video, Photography and Publishing.";;
        ubuntu-unity)     INFO="Ubuntu Unity|-|https://ubuntuunity.org/|Flavor of Ubuntu featuring the Unity7 desktop environment (the default desktop environment used by Ubuntu from 2010-2017).";;
        vanillaos)        INFO="Vanilla OS|-|https://vanillaos.org/|Designed to be a reliable and productive operating system for your daily work.";;
        void)             INFO="Void Linux|anon:voidlinux|https://voidlinux.org/|General purpose operating system. Its package system allows you to quickly install, update and remove software; software is provided in binary packages or can be built directly from sources.";;
        vxlinux)          INFO="VX Linux|-|https://vxlinux.org/|Pre-configured, secure systemd-free Plasma desktop with focus on convenience, performance and simplicity. Based on the excellent Void Linux.";;
        windows)          INFO="Windows|-|https://www.microsoft.com/en-us/windows/|Whether you’re gaming, studying, running a business, or running a household, Windows helps you get it done.";;
        windows-server)   INFO="Windows Server|-|https://www.microsoft.com/en-us/windows-server/|Platform for building an infrastructure of connected applications, networks, and web services.";;
        xubuntu)          INFO="Xubuntu|-|https://xubuntu.org/|Elegant and easy to use operating system. Xubuntu comes with Xfce, which is a stable, light and configurable desktop environment.";;
        zorin)            INFO="Zorin OS|-|https://zorin.com/os/|Alternative to Windows and macOS designed to make your computer faster, more powerful, secure, and privacy-respecting.";;
    esac
    echo "${INFO}"
}

function show_os_info() {
    echo
    echo -e "$(os_info "${1}" | cut -d'|' -f 1)"
    echo -e " - Credentials:\t$(os_info "${1}" | cut -d'|' -f 2)"
    echo -e " - Website:\t$(os_info "${1}" | cut -d'|' -f 3)"
    echo -e " - Description:\t$(os_info "${1}" | cut -d'|' -f 4)"
}

function pretty_name() {
    os_info "${1}" | cut -d'|' -f 1
}

# Just in case quickget want use it
function os_homepage() {
    os_info "${1}" | cut -d'|' -f 4
}

function error_specify_os() {
    echo "ERROR! You must specify an operating system."
    echo "- Supported Operating Systems:"
    os_support | fmt -w 80
    echo -e "\nTo see all possible arguments, use:\n   quickget -h  or  quickget --help"
    exit 1
}

function os_supported() {
    if [[ ! "$(os_support)" =~ ${OS} ]]; then
        echo -e "ERROR! ${OS} is not a supported OS.\n"
        os_support | fmt -w 80
        exit 1
    fi
}

function error_specify_release() {
    show_os_info "${OS}"
    case ${OS} in
        *ubuntu-server*)
            echo -en " - Releases:\t"
            releases_ubuntu-server
            ;;
        *ubuntu*)
            echo -en " - Releases:\t"
            releases_ubuntu
            ;;
        *windows*)
            echo -en " - Releases:\t"
            "releases_${OS}"
            echo -en " - Languages:\t"
            "languages_${OS}"
            echo "${I18NS[@]}"
            ;;
        *)
            echo -en " - Releases:\t"
            "releases_${OS}" | fmt -w 80
            if [[ $(type -t "editions_${OS}") == function ]]; then
                echo -en " - Editions:\t"
                "editions_${OS}" | fmt -w 80
            fi
            ;;
    esac
    echo -e "\nERROR! You must specify a release."
    exit 1
}

function error_not_supported_release() {
    if [[ ! "${RELEASES[*]}" =~ ${RELEASE} ]]; then
        echo -e "ERROR! ${DISPLAY_NAME} ${RELEASE} is not a supported release.\n"
        echo -n ' - Supported releases: '
        "releases_${OS}"
        exit 1
    fi
}

function error_not_supported_lang() {
    echo -e "ERROR! ${I18N} is not a supported $(pretty_name "${OS}") language\n"
    echo -n ' - Editions: '
    for I18N in "${I18NS[@]}"; do
        echo -n "${I18N} "
    done
    exit 1
}

function error_not_supported_argument() {
    echo "ERROR! Not supported argument"
    echo "To see all possible arguments, use:"
    echo "   quickget -h  or  quickget --help"
    exit 1
}

function handle_missing() {
    # Handle odd missing Fedora combinations
    case "${OS}" in
        fedora)
            if [[ "${RELEASE}" -lt 40 && "${EDITION}" == "Onyx" ]] || [[ "${RELEASE}" -lt 40 && "${EDITION}" == "Sericea" ]]; then
                echo "ERROR! Unsupported combination"
                echo "       Fedora ${RELEASE} ${EDITION} is not available, please choose another Release or Edition"
                exit 1
            fi;;
    esac
}

function validate_release() {
    local DISPLAY_NAME=""
    local RELEASE_GENERATOR=""
    local RELEASES=""

    DISPLAY_NAME="$(pretty_name "${OS}")"
    case ${OS} in
        *ubuntu-server*) RELEASE_GENERATOR="releases_ubuntu-server";;
        *ubuntu*) RELEASE_GENERATOR="releases_ubuntu";;
        *) RELEASE_GENERATOR="${1}";;
    esac
    RELEASES=$(${RELEASE_GENERATOR})
    error_not_supported_release
}

function list_json() {
    # Reference: https://stackoverflow.com/a/67359273
    list_csv | jq -R 'split(",") as $h|reduce inputs as $in ([]; . += [$in|split(",")|. as $a|reduce range(0,length) as $i ({};.[$h[$i]]=$a[$i])])'
    exit 0
}

function list_csv() {
    CSV_DATA="$(csv_data)"

    echo "Display Name,OS,Release,Option,Downloader,PNG,SVG"
    sort -t',' -k2,2 <<<"${CSV_DATA}"

    exit 0
}

function csv_data() {
    local DISPLAY_NAME
    local DL=""
    local DOWNLOADER
    local FUNC
    local OPTION
    local OS
    local PNG
    local RELEASE
    local SVG
    local HAS_ZSYNC=0

    # Check if zsync is available
    if command -v zsync &>/dev/null; then
        HAS_ZSYNC=1
    fi

    for OS in $(os_support); do
        local EDITIONS=""
        DISPLAY_NAME="$(pretty_name "${OS}")"

        case ${OS} in
            *ubuntu-server*) FUNC="ubuntu-server";;
            *ubuntu*) FUNC="ubuntu";;
            *) FUNC="${OS}";;
        esac

        PNG="https://quickemu-project.github.io/quickemu-icons/png/${FUNC}/${FUNC}-quickemu-white-pinkbg.png"
        SVG="https://quickemu-project.github.io/quickemu-icons/svg/${FUNC}/${FUNC}-quickemu-white-pinkbg.svg"

        if [[ $(type -t "editions_${OS}") == function ]]; then
            EDITIONS=$(editions_"${OS}")
        fi

        for RELEASE in $("releases_${FUNC}"); do
            if [[ "${OS}" == *"ubuntu"* ]] && [[ ${RELEASE} == *"daily"*  ]] && [ ${HAS_ZSYNC} -eq 1 ]; then
                DOWNLOADER="zsync"
            else
                DOWNLOADER="${DL}"
            fi

            # If the OS has an editions_() function, use it.
            if [[ ${EDITIONS} ]]; then
                for OPTION in ${EDITIONS}; do
                    echo "${DISPLAY_NAME},${OS},${RELEASE},${OPTION},${DOWNLOADER},${PNG},${SVG}"
                done
            elif [[ "${OS}" == "windows"* ]]; then
                "languages_${OS}"
                for I18N in "${I18NS[@]}"; do
                    echo "${DISPLAY_NAME},${OS},${RELEASE},${I18N},${DOWNLOADER},${PNG},${SVG}"
                done
            else
                echo "${DISPLAY_NAME},${OS},${RELEASE},,${DOWNLOADER},${PNG},${SVG}"
            fi
        done &
    done
    wait
}

function create_config() {
    local VM_PATH="${1}"
    local INPUT="${2}"
    OS="custom"
    if ! mkdir "${VM_PATH}" 2>/dev/null; then
        echo "ERROR! Could not create directory: ${VM_PATH}. Please verify that it does not already exist"
        exit 1
    fi
    if [[ "${INPUT}" == "http://"* ]] || [[ "${INPUT}" == "https://"* ]]; then
        INPUT="$(web_redirect "${INPUT}")"
        if [[ "${INPUT}" == *".iso" ]] || [[ "${INPUT}" == *".img" ]]; then
            web_get "${INPUT}" "${VM_PATH}"
            INPUT="${VM_PATH}/${INPUT##*/}"
        else
            echo "ERROR! Only ISO,IMG and QCOW2 file types are supported for --create-config"
            exit 1
        fi
    fi
    if [[ "${INPUT}" == *".iso" ]]; then
        echo "Moving image to VM dir" && mv "${INPUT}" "${VM_PATH}"
        CUSTOM_IMAGE_TYPE="iso"
    elif [[ "${INPUT}" == *".img" ]]; then
        echo "Moving image to VM dir" && mv "${INPUT}" "${VM_PATH}"
        CUSTOM_IMAGE_TYPE="img"
    elif [[ "${INPUT}" == *".qcow2" ]]; then
        echo "Moving image to VM dir" && mv "${INPUT}" "${VM_PATH}/disk.qcow2"
        CUSTOM_IMAGE_TYPE="qcow2"
    else
        echo "ERROR! Only ISO,IMG and QCOW2 file types are supported for --create-config"
        exit 1
    fi
    echo "Creating custom VM config for ${INPUT##*/}."
    case "${INPUT,,}" in
        *windows-server*) CUSTOM_OS="windows-server";;
        *windows*) CUSTOM_OS="windows";;
        *freebsd*) CUSTOM_OS="freebsd";;
        *kolibrios*) CUSTOM_OS="kolibrios";;
        *reactos*) CUSTOM_OS="reactos";;
        *) CUSTOM_OS="linux";;
    esac
    echo "Selecting OS: ${CUSTOM_OS}. If this is incorrect, please modify the config file to include the correct OS."
    echo
    make_vm_config "${INPUT}"
}

function list_supported() {
    list_csv | cut -d ',' -f2,3,4 | tr ',' ' '
    exit 0
}

function test_result() {
    local OS="${1}"
    local RELEASE="${2}"
    local EDITION="${3:-}"
    local URL="${4:-}"
    local RESULT="${5:-}"
    if [ -n "${EDITION}" ]; then
        OS="${OS}-${RELEASE}-${EDITION}"
    else
        OS="${OS}-${RELEASE}"
    fi

    if [ -n "${RESULT}" ]; then
        # Pad the OS string for consistent output
        OS=$(printf "%-35s" "${OS}")
        echo -e "${RESULT}: ${OS} ${URL}"
    else
        OS=$(printf "%-36s" "${OS}:")
        echo -e "${OS} ${URL}"
    fi
}

function test_all() {
    OS="${1}"
    os_supported

    local CHECK=""
    local FUNC="${OS}"
    if [[ "${OS}" == *ubuntu* && "${OS}" != "ubuntu-server" ]]; then
        FUNC="ubuntu"
    fi
    local URL=""

    for RELEASE in $("releases_${FUNC}"); do
        if [[ $(type -t "editions_${OS}") == function ]]; then
            for EDITION in $(editions_"${OS}"); do
                validate_release releases_"${OS}"
                URL=$(get_"${OS}" | cut -d' ' -f1 | head -n 1)
                if [ "${OPERATION}" == "show" ]; then
                    test_result "${OS}" "${RELEASE}" "${EDITION}" "${URL}"
                elif [ "${OPERATION}" == "test" ]; then
                    CHECK=$(web_check "${URL}" && echo "PASS" || echo "FAIL")
                    test_result "${OS}" "${RELEASE}" "${EDITION}" "${URL}" "${CHECK}"
                fi
            done
        elif [[ "${OS}" == "windows"* ]]; then
            "languages_${OS}"
            for I18N in "${I18NS[@]}"; do
                validate_release releases_"${OS}"
                if [ "${OPERATION}" == "show" ]; then
                    test_result "${OS}" "${RELEASE}" "${I18N}" ""
                elif [ "${OPERATION}" == "test" ]; then
                    test_result "${OS}" "${RELEASE}" "${I18N}" "${URL}" "SKIP"
                fi
            done
        elif [[ "${OS}" == "macos" ]]; then
            validate_release releases_macos
            (get_macos)
        elif [ "${OS}" == "ubuntu-server" ]; then
            validate_release releases_ubuntu-server
            (get_ubuntu-server)
        elif [[ "${OS}" == *ubuntu* ]]; then
            validate_release releases_ubuntu
            (get_ubuntu)
        else
            validate_release releases_"${OS}"
            URL=$(get_"${OS}" | cut -d' ' -f1 | head -n 1)
            if [ "${OPERATION}" == "show" ]; then
                test_result "${OS}" "${RELEASE}" "${EDITION}" "${URL}"
            elif [ "${OPERATION}" == "test" ]; then
                CHECK=$(web_check "${URL}" && echo "PASS" || echo "FAIL")
                test_result "${OS}" "${RELEASE}" "${EDITION}" "${URL}" "${CHECK}"
            fi
        fi
    done
}

function os_support() {
    echo alma \
    alpine \
    android \
    antix \
    archcraft \
    archlinux \
    arcolinux \
    artixlinux \
    athenaos \
    batocera \
    bazzite \
    biglinux \
    blendos \
    bodhi \
    bunsenlabs \
    cachyos \
    centos-stream \
    chimeralinux \
    crunchbang++ \
    debian \
    deepin \
    devuan \
    dragonflybsd \
    easyos \
    edubuntu \
    elementary \
    endeavouros \
    endless \
    fedora \
    freebsd \
    freedos \
    garuda \
    gentoo \
    ghostbsd \
    gnomeos \
    guix \
    haiku \
    holoiso \
    kali \
    kdeneon \
    kolibrios \
    kubuntu \
    linuxlite \
    linuxmint \
    lmde \
    lubuntu \
    macos \
    mageia \
    manjaro \
    mxlinux \
    netboot \
    netbsd \
    nitrux \
    nixos \
    nwg-shell \
    openbsd \
    openindiana \
    opensuse \
    oraclelinux \
    parrotsec \
    peppermint \
    popos \
    porteus \
    primtux \
    pureos \
    reactos \
    rebornos \
    rockylinux \
    siduction \
    slackware \
    slax \
    slint \
    slitaz \
    solus \
    sparkylinux \
    spirallinux \
    tails \
    tinycore \
    trisquel \
    truenas-core \
    truenas-scale \
    tuxedo-os \
    ubuntu \
    ubuntu-budgie \
    ubuntu-mate \
    ubuntu-server \
    ubuntu-unity \
    ubuntucinnamon \
    ubuntukylin \
    ubuntustudio \
    vanillaos \
    void \
    vxlinux \
    windows \
    windows-server \
    xubuntu \
    zorin
}

function releases_alma() {
    echo 9 8
}

function editions_alma() {
    echo boot minimal dvd
}

function releases_alpine() {
    local REL=""
    local RELS=""
    RELS=$(web_pipe "https://dl-cdn.alpinelinux.org/alpine/" | grep '"v' | cut -d'"' -f2 | tr -d / | sort -Vr | head -n 10)
    for REL in ${RELS}; do
        if web_check "https://dl-cdn.alpinelinux.org/alpine/${REL}/releases/x86_64/"; then
            echo -n "${REL} "
        fi
    done
}

function releases_android() {
    echo 9.0 8.1 7.1
}

function editions_android() {
    echo x86_64 x86
}

function releases_antix() {
    echo 23.1 23 22 21
}

function editions_antix() {
    echo net-sysv core-sysv base-sysv full-sysv net-runit core-runit base-runit full-runit
}

function releases_archcraft() {
    echo latest
}

function releases_archlinux() {
    echo latest
}

function releases_arcolinux() {
    #shellcheck disable=SC2046,SC2005
    # breaking change in v24.05
    # v24.05.1 is the first release with the new naming scheme and too complex to parse old and new so just show the new
    echo $(web_pipe "https://mirror.accum.se/mirror/arcolinux.info/iso/" | grep -o -E -e "v24.0[5-9].[[:digit:]]{2}"  -e "v24.1[0-2].[[:digit:]]{2}" | sort -ru | head -n 5)
}

function editions_arcolinux() {
    echo net plasma pro
}

function releases_artixlinux() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://mirror1.artixlinux.org/iso/" | grep "artix-" | cut -d'"' -f2 | grep -v sig | cut -d'-' -f 4 | sort -ru | tail -n 1)
}

function editions_artixlinux() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://mirror1.artixlinux.org/iso/" | grep "artix-" | cut -d'"' -f2 | grep -v sig | cut -d'-' -f2-3 | sort -u)
}

function releases_athenaos() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://api.github.com/repos/Athena-OS/athena/releases" | grep 'download_url' | grep rolling | cut -d'/' -f8 | sort -u)
}

function releases_batocera() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://mirrors.o2switch.fr/batocera/x86_64/stable/" | grep ^\<a | cut -d'"' -f2 | cut -d '/' -f1 | grep -v '\.' | sort -ru | tail -n +2 | head -n 5)
}

function releases_bazzite() {
    echo latest
}

function editions_bazzite() {
    echo gnome kde
}

function releases_biglinux() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://iso.biglinux.com.br" | grep -Eo 'biglinux_[0-9]{4}(-[0-9]{2}){2}_k[0-9]{2,3}.iso' | cut -d'_' -f2 | sort -ru | head -n 1)
}

function editions_biglinux() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://iso.biglinux.com.br" | grep -Eo "biglinux_$(releases_biglinux)_k[0-9]{2,3}.iso" | cut -d'_' -f3 | cut -d'.' -f1 | sort -Vru)
}

function releases_blendos() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://mirror.ico277.xyz/blendos/gnome/" | grep "\.iso" | cut -c81- | cut -d'"' -f2 | cut -d'-' -f2)
}

function editions_blendos() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://mirror.ico277.xyz/blendos/" | grep "\[DIR\]" | cut -c81-90 | cut -d'/' -f1 | grep -v testing | sort -u)
}

function releases_bodhi() {
    echo 7.0.0
}

function editions_bodhi() {
    echo standard hwe s76
}

function releases_bunsenlabs() {
    echo boron
}

function releases_cachyos() {
    echo latest
}

function editions_cachyos() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://mirror.cachyos.org/ISO/" | grep "title=" | grep -v testing | grep -v cli | cut -d'"' -f4 | cut -d '/' -f1 | sort)
}

function releases_centos-stream() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://linuxsoft.cern.ch/centos-stream/" | grep "\-stream" | cut -d'"' -f 6 | cut -d'-' -f 1)
}

function editions_centos-stream() {
    echo boot dvd1
}

function releases_chimeralinux() {
    echo latest
}

function editions_chimeralinux() {
    echo base gnome
}

function releases_crunchbang++() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://api.github.com/repos/CBPP/cbpp/releases" | grep 'download_url' | cut -d'-' -f2 | grep '^[0-9]' | sort -gru)
}

function releases_debian() {
    local ARCHIVE=""
    local MAJ=""
    local NEW=""
    local OLD=""
    NEW=$(web_pipe "https://cdimage.debian.org/debian-cd/" | grep '\.[0-9]/' | cut -d'>' -f 9 | cut -d'/' -f 1)
    echo -n "${NEW}"
    MAJ=$(echo "${NEW}" | cut -d'.' -f 1)
    ARCHIVE="$(web_pipe "https://cdimage.debian.org/cdimage/archive/" | grep folder | grep -v NEVER | cut -d'"' -f 6)"
    for i in {1..2}; do
        CUR=$((MAJ - i))
        OLD=$(grep ^"${CUR}"  <<< "${ARCHIVE}" | tail -n 1 | tr -d '/')
        echo -n " ${OLD}"
    done
    echo
}

function editions_debian() {
    echo standard cinnamon gnome kde lxde lxqt mate xfce netinst
}

function releases_deepin() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://mirrors.kernel.org/deepin-cd/" | grep "href=" | cut -d'"' -f2 | grep -v "\.\." | grep -v nightly | grep -v preview | sed 's|/||g' | tail -n 10 | sort -r)
}

function releases_devuan() {
    echo daedalus chimaera beowulf
}

function releases_dragonflybsd() {
    # If you remove "".bz2" from the end of the searched URL, you will get only the current release - currently 6.4.0
    # We could add a variable so this behaviour is optional/switchable (maybe from option or env)
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "http://mirror-master.dragonflybsd.org/iso-images/" | grep -E -o '"dfly-x86_64-.*_REL.iso.bz2"' | grep -o -E '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+')
}

function releases_easyos() {
    #local Y2023=""
    #local Y2024=""
    #Y2024=$(web_pipe https://distro.ibiblio.org/easyos/amd64/releases/kirkstone/2024/ | grep "tr class" | tail -n +2 | cut -d'"' -f6 | cut -d'/' -f1 | sort -r)
    #Y2023=$(web_pipe https://distro.ibiblio.org/easyos/amd64/releases/kirkstone/2023/ | grep "tr class" | tail -n +2 | cut -d'"' -f6 | cut -d'/' -f1 | sort -r)
    #echo -n ${2024}
    #echo ${Y2023}
    # Not dynamic for now
    echo 5.7 5.6.7 5.6.6 5.6.5 5.6.4 5.6.3 5.6.2 5.6.1
}

function releases_elementary() {
    echo 7.1 7.0
}

function releases_endeavouros() {
    local ENDEAVOUR_RELEASES=""
    ENDEAVOUR_RELEASES="$(web_pipe "https://mirror.alpix.eu/endeavouros/iso/" | grep -o '<a href="[^"]*.iso">' | sed 's/^<a href="//;s/.iso">.*//' | grep -v 'x86_64' | LC_ALL="en_US.UTF-8" sort -Mr | cut -c 13- | head -n 5 | tr '\n' ' ')"
    echo "${ENDEAVOUR_RELEASES,,}"
}

function releases_endless() {
    echo 5.1.1
}

function editions_endless() {
    echo base en fr pt_BR es
}

function releases_fedora() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://getfedora.org/releases.json" | jq -r 'map(.version) | unique | .[]' | sort -r)
}

function editions_fedora() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://getfedora.org/releases.json" | jq -r 'map(select(.arch=="x86_64" and .variant!="Labs" and .variant!="IoT" and .variant!="Container" and .variant!="Cloud" and .variant!="Everything"  and .subvariant!="Security" and .subvariant!="Server_KVM" and .subvariant!="SoaS")) | map(.subvariant) | unique | .[]')
}

function releases_freebsd() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://download.freebsd.org/ftp/releases/amd64/amd64/" | grep -Eo "href=\"[0-9\.]+-RELEASE" | grep -oE '[0-9\.]+' | sort -r)
}

function editions_freebsd() {
    echo disc1 dvd1
}

function releases_freedos() {
    echo 1.3 1.2
}

function releases_garuda() {
    echo latest
}

function editions_garuda() {
    echo cinnamon dr460nized dr460nized-gaming gnome i3 kde-git kde-lite lxqt-kwin mate qtile sway wayfire xfce
}

function releases_gentoo() {
    echo latest
}

function editions_gentoo() {
    echo minimal livegui
}

function releases_ghostbsd() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://download.ghostbsd.org/releases/amd64/" | grep "href" | cut -d'"' -f2 | cut -d'/' -f1 | sort -r | tail -n +3 | head -n 3)
}

function editions_ghostbsd() {
    echo mate xfce
}

function releases_gnomeos() {
    #shellcheck disable=SC2046,SC2005
    echo "nightly" $(web_pipe "https://download.gnome.org/gnomeos/" | grep "title=" | awk -F'"' '{print $4}' | tr -d '/' | sort -nr)
}

function releases_guix() {
    echo 1.4.0 1.3.0
}

function releases_haiku() {
    echo r1beta4 r1beta3
}

function editions_haiku() {
    echo x86_64 x86_gcc2h
}

function releases_holoiso() {
    echo "latest"
}

function releases_kali() {
    echo current kali-weekly
}

function releases_kdeneon() {
    echo user testing unstable developer
}

function releases_kolibrios() {
    echo latest
}

function releases_linuxlite() {
    echo 6.6 6.4 6.2 6.0
}

function releases_linuxmint() {
    echo 21.3 21.2 21.1 21 20.3 20.2
}

function editions_linuxmint() {
    echo cinnamon mate xfce
}

function editions_lmde() {
    echo cinnamon
}

function releases_lmde() {
    echo 6
}

function releases_macos() {
    echo mojave catalina big-sur monterey ventura sonoma
}

function releases_mageia() {
    echo 9 8
}

function editions_mageia() {
    echo Plasma GNOME Xfce
}

function editions_manjaro() {
    echo full minimal
}

function releases_manjaro() {
    echo xfce gnome plasma cinnamon i3 sway
}

function releases_mxlinux() {
    echo 23.3
}

function editions_mxlinux() {
    echo Xfce KDE Fluxbox
}

function releases_netboot() {
    echo latest
}

function releases_netbsd() {
    # V8 is EOL so filter it out
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "http://cdn.netbsd.org/pub/NetBSD/iso/" | grep -o -E '"[[:digit:]]+\.[[:digit:]]+/"' | tr -d '"/' | grep -v ^8 | sort -nr | head -n 4)
}

function releases_nitrux() {
    echo latest
}

function releases_nixos() {
    # Lists unstable plus the two most recent releases
    #shellcheck disable=SC2046
    echo unstable $(web_pipe "https://nix-channels.s3.amazonaws.com/?delimiter=/" | grep -o -P '(?<=<Key>nixos-)[0-9]+.[0-9]+(?=</Key>)' | sort -nr | head -n +2)
}

function editions_nixos() {
    echo minimal plasma gnome
}

function releases_nwg-shell() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://sourceforge.net/projects/nwg-iso/rss?path=/" | grep 'url=' | grep '64.iso' | cut -d'/' -f12 | cut -d'-' -f3)
}

function releases_openbsd() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://mirror.leaseweb.com/pub/OpenBSD/" | grep -e '6\.[8-9]/' -e '[7-9]\.' | cut -d\" -f4 | tr -d '/' | sort -r)
}

function releases_openindiana() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://dlc.openindiana.org/isos/hipster/" | grep link | cut -d'/' -f 1 | cut -d '"' -f4 | sort -r | tail -n +2 | head -n 5)
}

function editions_openindiana() {
    echo gui text minimal
}

function releases_opensuse() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://download.opensuse.org/distribution/leap/" | grep 'class="name"' | cut -d '/' -f2 | grep -v 42 | sort -r) microos tumbleweed
}

function releases_oraclelinux() {
    echo 9.3 9.2 9.1 9.0 8.9 8.8 8.7 8.6 8.5 8.4 7.9 7.8 7.7
}

function releases_parrotsec() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://download.parrot.sh/parrot/iso/" | grep -o -P '(?<=href=")[0-9].*(?=/")' | sort -nr | head -n 1)
}

function editions_parrotsec() {
    echo home htb security
}

function releases_peppermint() {
    echo latest
}

function editions_peppermint() {
    echo devuan-xfce devuan-gnome debian-xfce debian-gnome
}

function releases_popos() {
    echo 22.04 21.10 20.04
}

function editions_popos() {
    echo intel nvidia
}

function releases_porteus() {
    echo 5.01
}

function editions_porteus() {
    echo cinnamon gnome kde lxde lxqt mate openbox xfce
}

function releases_primtux() {
    echo 7
}

function editions_primtux() {
    echo 2022-10
}

function releases_pureos() {
    web_pipe "https://www.pureos.net/download/" | grep -m 1 "downloads.puri" | cut -d '"' -f 2 | cut -d '-' -f 4
}

function editions_pureos() {
    echo gnome plasma
}

function releases_reactos() {
    echo latest
}

function releases_rebornos() {
    echo latest
}

function releases_rockylinux() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "http://dl.rockylinux.org/vault/rocky/" | grep "^<a href" | grep -v full | grep -v RC | grep -v ISO | cut -d'"' -f2 | tr -d / | sort -ru)
}

function editions_rockylinux() {
    echo minimal dvd boot
}

function releases_siduction() {
    echo latest
}

function editions_siduction() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://mirror.math.princeton.edu/pub/siduction/iso/Standing_on_the_Shoulders_of_Giants/" | grep folder | cut -d'"' -f8 | tr -d '/' | sort -u)
}

function releases_slackware() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://slackware.nl/slackware/slackware-iso/" | grep "slackware-" | cut -d'<' -f7 | cut -d'-' -f2 | sort -ru | head -n 5)
}

function releases_slax() {
    echo latest
}

function editions_slax() {
    echo debian slackware
}

function releases_slint() {
    echo "15.0-5"
}

function releases_slitaz() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "http://mirror.slitaz.org/iso/rolling/" | grep "class='iso'" | cut -d"'" -f4 | cut -d'-' -f3- | grep iso | cut -d'.' -f1 | sort -u)
}

function releases_solus() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://getsol.us/download/" | grep "isos" | grep Download | cut -d'-' -f 2 | sort -ru)
}

function editions_solus() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://getsol.us/download/" | grep "isos" | grep Download | cut -d'.' -f5 | cut -d'-' -f2- | sort -u)
}

function releases_sparkylinux() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://sparkylinux.org/download/stable/" | grep "ISO image" | cut -d'-' -f3 | sort -ru)
}

function editions_sparkylinux() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://sparkylinux.org/download/stable/" | grep "ISO image" | cut -d'-' -f5 | cut -d'.' -f 1 | sort -u)
}

function releases_spirallinux() {
    echo latest
}

function editions_spirallinux() {
    echo Plasma XFCE Mate LXQt Gnome Budgie Cinnamon Builder
}

function releases_tails() {
    echo stable
}

function releases_tinycore() {
    echo 15 14
}

function editions_tinycore() {
    echo Core TinyCore CorePlus CorePure64 TinyCorePure64
}

function releases_trisquel() {
    echo 11.0 10.0.1
}

function editions_trisquel() {
    echo mate lxde kde sugar
}

function releases_truenas() {
    if [[ ${OS} == truenas ]] ; then
        echo "ERROR! The supported TrueNAS OS values are truenas-core or truenas-scale"
        exit 1;
    fi
}

function releases_truenas-core() {
    echo 13
}

function releases_truenas-scale() {
    echo 23
}

function releases_tuxedo-os() {
    echo current
}

function releases_ubuntu() {
    local VERSION_DATA=""
    local SUPPORTED_VERSIONS=()
    VERSION_DATA="$(IFS=$'\n' web_pipe https://api.launchpad.net/devel/ubuntu/series | jq -r '.entries[]')"
    # shellcheck disable=SC2207
    SUPPORTED_VERSIONS=($(IFS=$'\n' jq -r 'select(.status=="Supported" or .status=="Current Stable Release") | .version' <<<"${VERSION_DATA}" | sort))
    case "${OS}" in
        ubuntu)
            echo "${SUPPORTED_VERSIONS[@]}" daily-live;;
        kubuntu|lubuntu|ubuntukylin|ubuntu-mate|ubuntustudio|xubuntu)
            # after 16.04
            echo "${SUPPORTED_VERSIONS[@]:1}" daily-live;;
        ubuntu-budgie)
            # after 18.04
            echo "${SUPPORTED_VERSIONS[@]:2}" daily-live;;
        edubuntu|ubuntu-unity|ubuntucinnamon)
            # after 23.10
            echo "${SUPPORTED_VERSIONS[@]:5}" daily-live;;
    esac
}

function releases_ubuntu-server() {
    local ALL_VERSIONS=()
    # shellcheck disable=SC2207
    ALL_VERSIONS=($(IFS=$'\n' web_pipe http://releases.ubuntu.com/streams/v1/com.ubuntu.releases:ubuntu-server.json | jq -r '.products[] | select(.arch=="amd64") | .version' | sort -rV))
    echo daily-live "${ALL_VERSIONS[@]}"
}

function releases_vanillaos() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://api.github.com/repos/Vanilla-OS/live-iso/releases" | grep 'download_url' | cut -d'/' -f8 | sort -ru)
}

function releases_void() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://repo-default.voidlinux.org/live/" | grep "^<a href=\"2" | cut -d'"' -f2 | tr -d '/' | sort -ru | head -n 3)
}

function editions_void() {
    echo glibc musl xfce-glibc xfce-musl
}

function releases_vxlinux() {
    #shellcheck disable=SC2046,SC2005
    echo $(web_pipe "https://github.com/VX-Linux/main/releases/latest" | grep -o -e 'releases/tag/[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]' | sort -u | cut -d'/' -f 3)
}

function releases_windows() {
    echo 11 10
}

function languages_windows() {
    I18NS=("Arabic" "Brazilian Portuguese" "Bulgarian" "Chinese (Simplified)" "Chinese (Traditional)" "Croatian" "Czech" "Danish" "Dutch" \
    "English (United States)" "English International" "Estonian" "Finnish" "French" "French Canadian" "German" "Greek" "Hebrew" "Hungarian" \
    "Italian" "Japanese" "Korean" "Latvian" "Lithuanian" "Norwegian" "Polish" "Portuguese" "Romanian" "Russian" "Serbian Latin" "Slovak" \
    "Slovenian" "Spanish" "Spanish (Mexico)" "Swedish" "Thai" "Turkish" "Ukrainian")
}

function releases_windows-server() {
    echo 2022 2019 2016
}

function languages_windows-server() {
    I18NS=("English (United States)" "Chinese (Simplified)" "French" "German" "Italian" "Japanese" "Russian" "Spanish")
}

function releases_zorin() {
    echo 17 16
}

function editions_zorin() {
    echo core64 lite64 education64
}

function check_hash() {
    local iso=""
    local hash=""
    local hash_algo=""
    if [ "${OPERATION}" == "download" ]; then
        iso="${1}"
    else
        iso="${VM_PATH}/${1}"
    fi
    hash="${2}"
    # Guess the hash algorithm by the hash length
    case ${#hash} in
        32) hash_algo=md5sum;;
        40) hash_algo=sha1sum;;
        64) hash_algo=sha256sum;;
        128) hash_algo=sha512sum;;
        *) echo "WARNING! Can't guess hash algorithm, not checking ${iso} hash."
            return;;
    esac
    echo -n "Checking ${iso} with ${hash_algo}... "
    if ! echo "${hash} ${iso}" | ${hash_algo} --check --status; then
        echo "ERROR!"
        echo "${iso} doesn't match ${hash}. Try running 'quickget' again."
        exit 1
    else
        echo "Good!"
    fi
}

# Download a file from the web and pipe it to stdout
function web_pipe() {
    curl --silent --location "${1}"
}

# Download a file from the web
function web_get() {
    local CHECK=""
    local HEADERS=()
    local URL="${1}"
    local DIR="${2}"
    local FILE=""
    local USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36"

    if [ -n "${3}" ]; then
        FILE="${3}"
    else
        FILE="${URL##*/}"
    fi

    # Process any URL redirections after the file name has been extracted
    URL=$(web_redirect "${URL}")

    # Process any headers
    while (( "$#" )); do
        if [ "${1}" == "--header" ]; then
            HEADERS+=("${1}" "${2}")
            shift 2
        else
            shift
        fi
    done

    # Test mode for ISO
    if [ "${OPERATION}" == "show" ]; then
        test_result "${OS}" "${RELEASE}" "${EDITION}" "${URL}"
        exit 0
    elif [ "${OPERATION}" == "test" ]; then
        CHECK=$(web_check "${URL}" && echo "PASS" || echo "FAIL")
        test_result "${OS}" "${RELEASE}" "${EDITION}" "${URL}" "${CHECK}"
        exit 0
    elif [ "${OPERATION}" == "download" ]; then
        DIR="$(pwd)"
    fi

    if [ "${DIR}" != "$(pwd)" ] && ! mkdir -p "${DIR}" 2>/dev/null; then
        echo "ERROR! Unable to create directory ${DIR}"
        exit 1
    fi

    if [[ ${OS} != windows && ${OS} != macos && ${OS} != windows-server ]]; then
        echo "Downloading $(pretty_name "${OS}") ${RELEASE} ${EDITION}"
        echo "- URL: ${URL}"
    fi

    if ! curl --progress-bar --location --output "${DIR}/${FILE}" --continue-at - --user-agent "${USER_AGENT}" "${HEADERS[@]}" -- "${URL}"; then
        echo "ERROR! Failed to download ${URL} with curl."
        rm -f "${DIR}/${FILE}"
    fi
}

# checks if a URL needs to be redirected and returns the final URL
function web_redirect() {
    local REDIRECT_URL=""
    local URL="${1}"
    # Check for URL redirections
    # Output to nonexistent directory so the download fails fast
    REDIRECT_URL=$(curl --silent --location --fail --write-out '%{url_effective}' --output /var/cache/${RANDOM}/${RANDOM} "${URL}")
    if [ "${REDIRECT_URL}" != "${URL}" ]; then
        echo "${REDIRECT_URL}"
    else
        echo "${URL}"
    fi
}

# checks if a URL is reachable
function web_check() {
    local HEADERS=()
    local URL="${1}"
    # Process any headers
    while (( "$#" )); do
        if [ "${1}" == "--header" ]; then
            HEADERS+=("${1}" "${2}")
            shift 2
        else
            shift
        fi
    done
    curl --silent --location --head --output /dev/null --fail --connect-timeout 30 --max-time 30 --retry 3 "${HEADERS[@]}" "${URL}"
}

function zsync_get() {
    local CHECK=""
    local DIR="${2}"
    local FILE="${1##*/}"
    local OUT=""
    local URL="${1}"
    # Test mode for ISO
    if [ "${OPERATION}" == "show" ]; then
        test_result "${OS}" "${RELEASE}" "${EDITION}" "${URL}"
        exit 0
    elif [ "${OPERATION}" == "test" ]; then
        CHECK=$(web_check "${URL}" && echo "PASS" || echo "FAIL")
        test_result "${OS}" "${RELEASE}" "${EDITION}" "${URL}" "${CHECK}"
        exit 0
    elif command -v zsync &>/dev/null; then
        if [ -n "${3}" ]; then
            OUT="${3}"
        else
            OUT="${FILE}"
        fi

        if ! mkdir -p "${DIR}" 2>/dev/null; then
            echo "ERROR! Unable to create directory ${DIR}"
            exit 1
        fi
        echo "Downloading $(pretty_name "${OS}") ${RELEASE} ${EDITION} from ${URL}"
        # Only force http for zsync - not earlier because we might fall through here
        if ! zsync "${URL/https/http}.zsync" -i "${DIR}/${OUT}" -o "${DIR}/${OUT}" 2>/dev/null; then
            echo "ERROR! Failed to download ${URL/https/http}.zsync"
            exit 1
        fi

        if [ -e "${DIR}/${OUT}.zs-old" ]; then
            rm "${DIR}/${OUT}.zs-old"
        fi
    else
        echo "INFO: zsync not found, falling back to curl"
        if [ -n "${3}" ]; then
            web_get "${1}" "${2}" "${3}"
        else
            web_get "${1}" "${2}"
        fi
    fi
}

function make_vm_config() {
    local CONF_FILE=""
    local IMAGE_FILE=""
    local ISO_FILE=""
    local IMAGE_TYPE=""
    local GUEST=""
    if [ "${OPERATION}" == "download" ]; then
        exit 0
    fi
    IMAGE_FILE="${1}"
    ISO_FILE="${2}"
    case "${OS}" in
        batocera)
            GUEST="batocera"
            IMAGE_TYPE="img";;
        custom)
            GUEST="${CUSTOM_OS}"
            IMAGE_TYPE="${CUSTOM_IMAGE_TYPE}";;
        dragonflybsd)
            GUEST="dragonflybsd"
            IMAGE_TYPE="iso";;
        easyos)
            GUEST="linux"
            IMAGE_TYPE="img";;
        freebsd|ghostbsd)
            GUEST="freebsd"
            IMAGE_TYPE="iso";;
        haiku)
            GUEST="haiku"
            IMAGE_TYPE="iso";;
        freedos)
            GUEST="freedos"
            IMAGE_TYPE="iso";;
        kolibrios)
            GUEST="kolibrios"
            IMAGE_TYPE="iso";;
        macos)
            GUEST="macos"
            IMAGE_TYPE="img";;
        netbsd)
            GUEST="netbsd"
            IMAGE_TYPE="iso";;
        openbsd)
            GUEST="openbsd"
            IMAGE_TYPE="iso";;
        openindiana)
            GUEST="solaris"
            IMAGE_TYPE="iso";;
        reactos)
            GUEST="reactos"
            IMAGE_TYPE="iso";;
        truenas*)
            GUEST="truenas"
            IMAGE_TYPE="iso";;
        ubuntu*)
            GUEST="linux"
            IMAGE_TYPE="iso"
            # If there is a point in the release, check if it is less than 16.04
            if [[ "${RELEASE}" != *"daily"* ]]; then
                if [ "${RELEASE//./}" -lt 1604 ]; then
                    GUEST="linux_old"
                fi
            fi
            ;;
        windows)
            GUEST="windows"
            IMAGE_TYPE="iso";;
        windows-server)
            GUEST="windows-server"
            IMAGE_TYPE="iso";;
        *)
            GUEST="linux"
            IMAGE_TYPE="iso";;
    esac

    CONF_FILE="${VM_PATH}.conf"

    if [ ! -e "${CONF_FILE}" ]; then
        echo "Making ${CONF_FILE}"
        cat << EOF > "${CONF_FILE}"
#!${QUICKEMU} --vm
guest_os="${GUEST}"
disk_img="${VM_PATH}/disk.qcow2"
${IMAGE_TYPE}="${VM_PATH}/${IMAGE_FILE}"
EOF
        echo " - Setting ${CONF_FILE} executable"
        chmod u+x "${CONF_FILE}"
        if [ -n "${ISO_FILE}" ]; then
            echo "fixed_iso=\"${VM_PATH}/${ISO_FILE}\"" >> "${CONF_FILE}"
        fi

        # OS specific tweaks
        case ${OS} in
            alma|athenaos|centos-stream|endless|garuda|gentoo|kali|nixos|oraclelinux|popos|rockylinux)
                echo "disk_size=\"32G\"" >> "${CONF_FILE}";;
            openindiana)
                echo "boot=\"legacy\"" >> "${CONF_FILE}"
                echo "disk_size=\"32G\"" >> "${CONF_FILE}";;
            batocera)
                echo "disk_size=\"8G\"" >> "${CONF_FILE}";;
            dragonflybsd|haiku|openbsd|netbsd|slackware|slax|tails|tinycore)
                echo "boot=\"legacy\"" >> "${CONF_FILE}";;
            deepin)
                echo "disk_size=\"64G\"" >> "${CONF_FILE}"
                echo "ram=\"4G\"" >> "${CONF_FILE}"
                ;;
            freedos)
                echo "boot=\"legacy\"" >> "${CONF_FILE}"
                echo "disk_size=\"4G\"" >> "${CONF_FILE}"
                echo "ram=\"256M\"" >> "${CONF_FILE}"
                ;;
            kolibrios)
                echo "boot=\"legacy\"" >> "${CONF_FILE}"
                echo "disk_size=\"2G\"" >> "${CONF_FILE}"
                echo "ram=\"128M\"" >> "${CONF_FILE}"
                ;;
            slint)
                echo "disk_size=\"50G\"" >> "${CONF_FILE}"
                ;;
            slitaz)
                echo "boot=\"legacy\"" >> "${CONF_FILE}"
                echo "disk_size=\"4G\"" >> "${CONF_FILE}"
                echo "ram=\"512M\"" >> "${CONF_FILE}"
                ;;
            truenas-scale|truenas-core)
                echo "boot=\"legacy\"" >> "${CONF_FILE}"
                # the rest is non-functional
                # echo "bootdrive_size=\"5G\"" >> "${CONF_FILE}" # boot drive
                # echo "1stdrive_size=\"20G\"" >> "${CONF_FILE}" # for testing
                # echo "2nddrive_size=\"20G\"" >> "${CONF_FILE}" # again, for testing
                ;;
            ubuntu-server)
                # 22.04+ fails on LVM build if disk size is < 10G
                # 22.04.1 fails on auto-install if TPM is disabled
                echo "disk_size=\"10G\"" >> "${CONF_FILE}"
                echo "ram=\"4G\"" >> "${CONF_FILE}"
                if [[ "${RELEASE}" == *"22.04"* ]]; then
                    echo "tpm=\"on\"" >> "${CONF_FILE}"
                fi
                ;;
            vanillaos)
                ## Minimum is 50G for abroot, but a 64GB is allocated to give some headroom
                echo "disk_size=\"64G\"" >> "${CONF_FILE}"
                ;;
            zorin)
                case ${EDITION} in
                    education64|edulite64) echo "disk_size=\"32G\"" >> "${CONF_FILE}";;
                esac;;
            reactos)
                echo "boot=\"legacy\"" >> "${CONF_FILE}"
                echo "disk_size=\"12G\"" >> "${CONF_FILE}"
                echo "ram=\"2048M\"" >> "${CONF_FILE}"
                ;;
            macos)
                echo "disk_size=\"128G\"" >> "${CONF_FILE}"
                echo "macos_release=\"${RELEASE}\"" >> "${CONF_FILE}"
                # https://github.com/quickemu-project/quickemu/issues/438
                if [ "${RELEASE}" == "monterey" ]; then
                    echo "cpu_cores=2" >> "${CONF_FILE}"
                fi
                ;;
        esac

        if [ "${OS}" == "ubuntu" ] && [[ ${RELEASE} == *"daily"*  ]]; then
            # Minimum to install lobster testing is 18GB but 32GB are allocated for headroom
            echo "disk_size=\"32G\"" >> "${CONF_FILE}"
        fi

        if [[ "${OS}" == "windows"* ]]; then
            echo "disk_size=\"64G\"" >> "${CONF_FILE}"
        fi

        # Enable TPM for Windows 11
        if [ "${OS}" == "windows" ] && [ "${RELEASE}" == "11" ] || [ "${OS}" == "windows-server" ] && [ "${RELEASE}" == "2022" ]; then
            echo "tpm=\"on\"" >> "${CONF_FILE}"
            echo "secureboot=\"off\"" >> "${CONF_FILE}"
        fi
    fi
    echo -e "\nTo start your $(pretty_name "${OS}") virtual machine run:"
    if [ "${OS}" == "slint" ]; then
        echo -e "    quickemu --vm ${CONF_FILE}\nTo start Slint with braille support run:\n    quickemu --vm --braille --display sdl ${CONF_FILE}"
    else
        echo "    quickemu --vm ${CONF_FILE}"
    fi

    echo
    exit 0
}

function get_alma() {
    local HASH=""
    local ISO="AlmaLinux-${RELEASE}-latest-x86_64-${EDITION}.iso"
    local URL="https://repo.almalinux.org/almalinux/${RELEASE}/isos/x86_64"
    HASH="$(web_pipe "${URL}/CHECKSUM" | grep "(${ISO}" | cut -d' ' -f4)"
    echo "${URL}/${ISO} ${HASH}"
}

function get_alpine() {
    local HASH=""
    local ISO=""
    local URL="https://dl-cdn.alpinelinux.org/alpine/${RELEASE}/releases/x86_64"
    local VERSION=""
    VERSION=$(web_pipe "${URL}/latest-releases.yaml" | awk '/"Xen"/{found=0} {if(found) print} /"Virtual"/{found=1}' | grep 'version:' | awk '{print $2}')
    ISO="alpine-virt-${VERSION}-x86_64.iso"
    HASH=$(web_pipe "${URL}/latest-releases.yaml" | awk '/"Xen"/{found=0} {if(found) print} /"Virtual"/{found=1}' | grep 'sha256:' | awk '{print $2}')
    echo "${URL}/${ISO} ${HASH}"
}

function get_android() {
    local HASH=""
    local ISO=""
    local JSON_ALL=""
    local JSON_REL=""
    local URL="https://mirrors.gigenet.com/OSDN/android-x86"
    JSON_ALL=$(web_pipe "https://www.fosshub.com/Android-x86-old.html" | grep "var settings =" | cut -d'=' -f2-)
    JSON_REL=$(echo "${JSON_ALL}" | jq --arg ver "${OS}-${EDITION}-${RELEASE}" 'first(.pool.f[] | select((.n | startswith($ver)) and (.n | endswith(".iso"))))')
    ISO=$(echo "${JSON_REL}" | jq -r .n)
    HASH=$(echo "${JSON_REL}" | jq -r .hash.sha256)
    # Traverse the directories to find the .iso location
    for DIR in $(web_pipe "${URL}" | grep -o -E '[0-9]{5}' | sort -ur); do
        if web_pipe "${URL}/${DIR}" | grep "${ISO}" &>/dev/null; then
            URL="${URL}/${DIR}"
            break
        fi
    done
    echo "${URL}/${ISO} ${HASH}"
}

function get_antix() {
    local HASH=""
    local ISO="antiX-${RELEASE}"
    local README="README"
    local URL="https://sourceforge.net/projects/antix-linux/files/Final/antiX-${RELEASE}"

    # antiX uses a different URL and ISO naming for runit editions
    if [[ "${EDITION}" == *"runit"* ]];then
        ISO+="-runit"
        README="README2"
        case ${RELEASE} in
            21) URL+="/runit-bullseye";;
            *)  URL+="/runit-antiX-${RELEASE}";;
        esac
    fi
    case ${EDITION} in
        base-*) ISO+="_x64-base.iso";;
        core-*) ISO+="_x64-core.iso";;
        full-*) ISO+="_x64-full.iso";;
        net-*)  ISO+="-net_x64-net.iso";;
    esac
    HASH=$(web_pipe "${URL}/${README}.txt" | grep "${ISO}" | cut -d' ' -f1 | head -n 1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_archcraft() {
    local HASH=""
    local URL=""
    URL="https://sourceforge.net/projects/archcraft/files/${RELEASE}/download"
    echo "${URL} ${HASH}"
}

function get_archlinux() {
    local HASH=""
    local ISO=""
    local URL="https://mirror.rackspace.com/archlinux"
    ISO=$(web_pipe "https://archlinux.org/releng/releases/json/" | jq -r '.releases[0].iso_url')
    HASH=$(web_pipe "https://archlinux.org/releng/releases/json/" | jq -r '.releases[0].sha256_sum')
    echo "${URL}${ISO} ${HASH}"
}

function get_arcolinux() {
    local HASH=""
    local ISO=""
    local URL=""
    URL="https://mirror.accum.se/mirror/arcolinux.info/iso/${RELEASE}"
    ISO="arco${EDITION}-${RELEASE}-x86_64.iso"
    HASH=$(web_pipe "${URL}/${ISO}.sha256" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_artixlinux() {
    local HASH=""
    local ISO=""
    local URL="https://iso.artixlinux.org/iso"
    ISO="artix-${EDITION}-${RELEASE}-x86_64.iso"
    HASH=$(web_pipe "${URL}/sha256sums" | grep "${ISO}")
    echo "${URL}/${ISO} ${HASH}"
}

function get_athenaos() {
    local HASH=""
    local URL="https://github.com/Athena-OS/athena/releases/download/${RELEASE}"
    local ISO="athena-rolling-x86_64.iso"
    HASH=$(web_pipe "${URL}/${ISO}.sha256" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_batocera() {
    local HASH=""
    local ISO=""
    local URL="https://mirrors.o2switch.fr/batocera/x86_64/stable/${RELEASE}"
    ISO="$(web_pipe "${URL}/" | grep -e 'batocera.*img.gz'| cut -d'"' -f2)"
    echo "${URL}/${ISO} ${HASH}"
}

function get_bazzite() {
    local HASH=""
    local ISO=""
    local URL="https://download.bazzite.gg"
    case ${EDITION} in
        gnome) ISO="bazzite-gnome-stable.iso";;
        kde)  ISO="bazzite-stable.iso";;
    esac
    HASH=$(web_pipe "${URL}/${ISO}-CHECKSUM" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_biglinux() {
    local HASH=""
    local ISO="biglinux_${RELEASE}_${EDITION}.iso"
    local URL="https://iso.biglinux.com.br"
    HASH=$(web_pipe "${URL}/${ISO}.md5" | grep -Eo '[[:alnum:]]{32}')
    echo "${URL}/${ISO} ${HASH}"
}

function get_blendos() {
    local HASH=""
    local ISO="blendos-${RELEASE}-stable-${EDITION}.iso"
    local URL="https://mirror.ico277.xyz/blendos/${EDITION}"
    echo "${URL}/${ISO} ${HASH}"
}

function get_bodhi() {
    local HASH=""
    local ISO=""
    local URL="https://sourceforge.net/projects/bodhilinux/files/${RELEASE}"
    case ${EDITION} in
        standard) ISO="bodhi-${RELEASE}-64.iso";;
        *) ISO="bodhi-${RELEASE}-64-${EDITION}.iso";;
    esac
    HASH=$(web_pipe "${URL}/${ISO}.sha256" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_bunsenlabs() {
    local HASH=""
    local ISO="boron-1-240123-amd64.hybrid.iso"
    local URL="https://ddl.bunsenlabs.org/ddl"
    HASH=$(web_pipe "${URL}/release.sha256.txt" | head -n 1 | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_cachyos() {
    local HASH=""
    local REL=""
    local URL="https://mirror.cachyos.org/ISO/${EDITION}/"
    REL=$(web_pipe "${URL}" | grep -o '>[0-9]*/</a>' | grep -o '[0-9]*' | sort -ru | tail -n 1)
    local ISO="cachyos-${EDITION}-linux-${REL}.iso"
    HASH=$(web_pipe "${URL}/${REL}/${ISO}.sha256" | cut -d' ' -f1)
    echo "${URL}/${REL}/${ISO} ${HASH}"
}

function get_centos-stream() {
    local HASH=""
    local ISO="CentOS-Stream-${RELEASE}-latest-x86_64-${EDITION}.iso"
    local URL="https://linuxsoft.cern.ch/centos-stream/${RELEASE}-stream/BaseOS/x86_64/iso"
    HASH=$(web_pipe "${URL}/${ISO}.SHA256SUM" | grep "SHA256 (${ISO}" | cut -d' ' -f4)
    echo "${URL}/${ISO} ${HASH}"
}

function get_chimeralinux() {
    local DATE=""
    local HASH=""
    local URL="https://repo.chimera-linux.org/live/${RELEASE}"
    DATE=$(web_pipe "${URL}/sha256sums.txt" | head -n1 | cut -d'-' -f5)
    local ISO="chimera-linux-x86_64-LIVE-${DATE}-${EDITION}.iso"
    HASH=$(web_pipe "${URL}/sha256sums.txt" | grep 'x86_64-LIVE' | grep "${EDITION}" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_crunchbang++() {
    local HASH=""
    local ISO=""
    ISO=$(web_pipe "https://api.github.com/repos/CBPP/cbpp/releases" | grep 'download_url' | grep amd64 | grep "${RELEASE}" | cut -d'"' -f4)
    echo "${ISO} ${HASH}"
}

function get_debian() {
    local DEBCURRENT=""
    local HASH=""
    local ISO="debian-live-${RELEASE}-amd64-${EDITION}.iso"
    local URL="https://cdimage.debian.org/cdimage/archive/${RELEASE}-live/amd64/iso-hybrid"
    DEBCURRENT=$(web_pipe "https://cdimage.debian.org/debian-cd/" | grep '\.[0-9]/' | cut -d'>' -f 9 | cut -d'/' -f 1)
    case "${RELEASE}" in
        "${DEBCURRENT}") URL="https://cdimage.debian.org/debian-cd/${RELEASE}-live/amd64/iso-hybrid";;
    esac
    if [ "${EDITION}" == "netinst" ]; then
        URL="${URL/-live/}"
        URL="${URL/hybrid/cd}"
        ISO="${ISO/-live/}"
    fi
    HASH=$(web_pipe "${URL}/SHA512SUMS" | grep "${ISO}" | cut -d' ' -f1 | head -n 1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_deepin() {
    local HASH=""
    local REV=${RELEASE}
    # deepin-desktop-community-20.3-amd64.iso
    local URL="https://cdimage.deepin.com/releases/"${RELEASE}
    # Correct URL for 23-RC onwards which has architecture directories
    if [[ "${RELEASE}" == *"23-RC"* ]] ; then
        URL+="/amd64"
    fi
    local ISO="deepin-desktop-community-${REV}-amd64.iso"
    HASH=$(web_pipe "${URL}/SHA256SUMS" | grep "${ISO}" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_devuan() {
    local HASH=""
    local ISO=""
    local URL="https://files.devuan.org/devuan_${RELEASE}/desktop-live"
    local VER=""
    case ${RELEASE} in
        beowulf)  VER="3.1.1";;
        chimaera) VER="4.0.3";;
        daedalus) VER="5.0.0";;
    esac
    ISO="devuan_${RELEASE}_${VER}_amd64_desktop-live.iso"
    HASH=$(web_pipe "${URL}/SHASUMS.txt" | grep "${ISO}" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_dragonflybsd() {
    local HASH=""
    local ISO="dfly-x86_64-${RELEASE}_REL.iso.bz2"
    local URL="http://mirror-master.dragonflybsd.org/iso-images"
    HASH=$(web_pipe "${URL}/md5.txt" | grep "(${ISO})" | cut -d' ' -f4)
    echo "${URL}/${ISO} ${HASH}"
}

function get_easyos() {
    local HASH=""
    local URL=""
    local ISO=""
    local YEAR=""
    ISO="easy-${RELEASE}-amd64.img"
    case ${RELEASE} in
        5.6.5|5.6.4|5.6.3|5.6.2|5.6.1) YEAR="2023";;
        5.7|5.6.7|5.6.6)               YEAR="2024";;
    esac
    URL="https://distro.ibiblio.org/easyos/amd64/releases/kirkstone/${YEAR}/${RELEASE}"
    HASH=$(web_pipe "${URL}/md5.sum.txt" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_elementary() {
    local HASH=""
    case ${RELEASE} in
        7.0) STAMP="20230129rc";;
        7.1) STAMP="20230926rc";;
    esac
    local ISO="elementaryos-${RELEASE}-stable.${STAMP}.iso"
    local URL="https://ams3.dl.elementary.io/download"
    echo "${URL}/$(date +%s | base64)/${ISO} ${HASH}"
}

function get_endeavouros() {
    local ENDEAVOUR_RELEASES=""
    local HASH=""
    local ISO=""
    local URL="https://mirror.alpix.eu/endeavouros/iso"
    # Find EndeavourOS releases from mirror, pick one matching release
    ENDEAVOUR_RELEASES="$(web_pipe "${URL}/" | grep -o '<a href="[^"]*.iso">' | sed 's/^<a href="//;s/.iso">.*//' | grep -v 'x86_64')"
    ISO="$(echo "${ENDEAVOUR_RELEASES}" | grep -i "${RELEASE}").iso"
    HASH=$(web_pipe "${URL}/${ISO}.sha512sum" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_endless() {
    local HASH="" # No hash - there is a signature in .asc signed by
    #https://d1anzknqnc1kmb.cloudfront.net/eos-image-keyring.gpg
    # (4096R: CB50 0F7B C923 3FAD 32B4 E720 9E0C 1250 587A 279C)
    local FILE_TS=""
    # https://support.endlessos.org/en/installation/direct-download gives the info but computes the URLS in js
    # so parsing out the useful info is not happening tonight
    # Endless edition names are "base" for the small minimal one or the Language for the large full release
    # The isos are stamped as they are finished so ....
    case ${EDITION} in
        base)  FILE_TS="240103-025438";;
        en)    FILE_TS="240103-025437";;
        es)    FILE_TS="240103-025438";;
        fr)    FILE_TS="240103-025438";;
        pt_BR) FILE_TS="240103-030103";;
    esac
    URL="https://images-dl.endlessm.com/release/${RELEASE}/eos-amd64-amd64/${EDITION}"
    ISO="eos-eos${RELEASE:0:3}-amd64-amd64.${FILE_TS}.${EDITION}.iso"
    echo "${URL}/${ISO} ${HASH}"
}

function get_fedora() {
    local HASH=""
    local ISO=""
    local JSON=""
    local URL=""
    local VARIANT=""
    case ${EDITION} in
        Server|Kinoite|Onyx|Silverblue|Sericea|Workstation) VARIANT="${EDITION}";;
        *) VARIANT="Spins";;
    esac
    #shellcheck disable=SC2086
    JSON=$(web_pipe "https://getfedora.org/releases.json" | jq '.[] | select(.variant=="'${VARIANT}'" and .subvariant=="'"${EDITION}"'" and .arch=="x86_64" and .version=="'"${RELEASE}"'" and .sha256 != null)')
    URL=$(echo "${JSON}" | jq -r '.link' | head -n1)
    HASH=$(echo "${JSON}" | jq -r '.sha256' | head -n1)
    echo "${URL} ${HASH}"
}

function get_freebsd() {
    local HASH=""
    local ISO="FreeBSD-${RELEASE}-RELEASE-amd64-${EDITION}.iso"
    local URL="https://download.freebsd.org/ftp/releases/amd64/amd64/ISO-IMAGES/${RELEASE}"
    HASH=$(web_pipe "${URL}/CHECKSUM.SHA256-FreeBSD-${RELEASE}-RELEASE-amd64" | grep "${ISO}" | grep -v ".xz" | cut -d' ' -f4)
    echo "${URL}/${ISO} ${HASH}"
}

function get_freedos() {
    local HASH=""
    local ISO=""
    local URL="http://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/${RELEASE}/official"
    case ${RELEASE} in
        1.2) ISO="FD12CD.iso"
             HASH=$(web_pipe "${URL}/FD12.sha" | grep "${ISO}" | cut -d' ' -f1);;
        1.3) ISO="FD13-LiveCD.zip"
             HASH=$(web_pipe "${URL}/verify.txt" | grep -A 8 "sha256sum" | grep "${ISO}" | cut -d' ' -f1);;
    esac
    echo "${URL}/${ISO} ${HASH}"
}

function get_garuda() {
    local HASH=""
    local ISO=""
    local URL="https://iso.builds.garudalinux.org/iso/latest/garuda"
    ISO=${EDITION}/latest.iso
    HASH="$(web_pipe "${URL}/${ISO}.sha256" | cut -d' ' -f1)"
    echo "${URL}/${ISO} ${HASH}"
}

function get_gentoo() {
    local HASH=""
    local ISO=""
    local URL="https://mirror.bytemark.co.uk/gentoo/releases/amd64/autobuilds"
    case ${EDITION} in
        minimal) ISO=$(web_pipe "${URL}/${RELEASE}-iso.txt" | grep install | cut -d' ' -f1);;
        livegui) ISO=$(web_pipe "${URL}/${RELEASE}-iso.txt" | grep livegui | cut -d' ' -f1);;
    esac
    HASH=$(web_pipe "${URL}/${ISO}.DIGESTS" | grep -A 1 SHA512 | grep iso | grep -v CONTENTS | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_ghostbsd() {
    local ISO=""
    local URL="https://download.ghostbsd.org/releases/amd64/${RELEASE}"
    local HASH=""
    case ${EDITION} in
        mate) ISO="GhostBSD-${RELEASE}.iso";;
        xfce) ISO="GhostBSD-${RELEASE}-XFCE.iso";;
    esac
    HASH=$(web_pipe "${URL}/${ISO}.sha256" | grep "${ISO}" | cut -d' ' -f4)
    echo "${URL}/${ISO} ${HASH}"
}

function get_gnomeos() {
    local HASH=""
    local ISO="gnome_os_installer_${RELEASE}.iso"
    local URL="https://download.gnome.org/gnomeos/${RELEASE}"
    case ${RELEASE} in
        nightly)
            ISO="gnome_os_installer.iso"
            URL="https://os.gnome.org/download/latest";;
        46.0) ISO="gnome_os_installer_46.iso";;
        3*) ISO="gnome_os_installer.iso";;
    esac
    # Process the URL redirections; required for GNOME
    ISO=$(web_redirect "${URL}/${ISO}")
    echo "${ISO} ${HASH}"
}

function get_guix() {
    local HASH=""
    local ISO="guix-system-install-${RELEASE}.x86_64-linux.iso"
    local URL="https://ftpmirror.gnu.org/gnu/guix/"
    echo "${URL}/${ISO} ${HASH}"
}

function get_haiku() {
    local ISO="haiku-${RELEASE}-${EDITION}-anyboot.iso"
    local URL="http://mirror.rit.edu/haiku/${RELEASE}"
    HASH=$(web_pipe "${URL}/${ISO}.sha256" | grep "${ISO}" | cut -d' ' -f4)
    echo "${URL}/${ISO} ${HASH}"
}

function get_holoiso() {
    local HASH=""
    local URL=""
    RELEASE="$(web_pipe "https://github.com/HoloISO/releases/releases" | grep -o -e 'releases/tag/[[:digit:]]\+\(\.[[:digit:]]\+\)*' | head -n 1 | cut -d'/' -f 3)"
    URL=$(web_pipe "https://api.github.com/repos/HoloISO/releases/releases" | jq -r ".[] | select(.tag_name==\"${RELEASE}\") | .body" | sed -n 's/.*\(https:\/\/[^ ]*holoiso\.ru\.eu\.org\/[^ ]*\.iso\).*/\1/p' | head -n 1)
    echo "${URL} ${HASH}"
}

function get_kali() {
    local HASH=""
    local ISO=""
    local URL="https://cdimage.kali.org/${RELEASE}"
    ISO=$(web_pipe "${URL}/?C=M;O=D" | grep -o ">kali-linux-.*-installer-amd64.iso" | head -n 1 | cut -c 2-)
    HASH=$(web_pipe "${URL}/SHA256SUMS" | grep -v torrent | grep "${ISO}" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_kdeneon() {
    local HASH=""
    local ISO=""
    local URL="https://files.kde.org/neon/images/${RELEASE}/current"
    ISO=$(web_pipe "${URL}/neon-${RELEASE}-current.sha256sum" | cut -d' ' -f3-)
    HASH=$(web_pipe "${URL}/neon-${RELEASE}-current.sha256sum" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_kolibrios() {
    local HASH=""
    local ISO="kolibri.iso"
    local URL="https://builds.kolibrios.org/eng"
    echo "${URL}/${ISO} ${HASH}"
}

function get_linuxlite() {
    local HASH=""
    local ISO="linux-lite-${RELEASE}-64bit.iso"
    local URL="https://sourceforge.net/projects/linux-lite/files/${RELEASE}"
    HASH=$(web_pipe "${URL}/${ISO}.sha256" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_linuxmint() {
    local HASH=""
    local ISO="linuxmint-${RELEASE}-${EDITION}-64bit.iso"
    local URL="https://mirror.bytemark.co.uk/linuxmint/stable/${RELEASE}"
    HASH=$(web_pipe "${URL}/sha256sum.txt" | grep "${ISO}" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_lmde() {
    local HASH=""
    local ISO="lmde-${RELEASE}-${EDITION}-64bit.iso"
    local URL="https://mirror.bytemark.co.uk/linuxmint/debian"
    HASH=$(web_pipe "${URL}/sha256sum.txt" | grep "${ISO}" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function generate_id() {
    local macRecoveryID=""
    local TYPE="${1}"
    local valid_chars=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F")
    for ((i=0; i<TYPE; i++)); do
        macRecoveryID+="${valid_chars[$((RANDOM % 16))]}"
    done
    echo "${macRecoveryID}"
}

function get_macos() {
    local appleSession=""
    local info=""
    local downloadLink=""
    local downloadSession=""
    local chunkListLink=""
    local chunkListSession=""
    local BOARD_ID=""
    local CWD=""
    local CHECK=""
    local CHUNKCHECK=""
    local MLB="00000000000000000"
    local OS_TYPE="default"

    case ${RELEASE} in
        lion|10.7)
            BOARD_ID="Mac-2E6FAB96566FE58C"
            MLB="00000000000F25Y00";;
        mountainlion|10.8)
            BOARD_ID="Mac-7DF2A3B5E5D671ED"
            MLB="00000000000F65100";;
        mavericks|10.9)
            BOARD_ID="Mac-F60DEB81FF30ACF6"
            MLB="00000000000FNN100";;
        yosemite|10.10)
            BOARD_ID="Mac-E43C1C25D4880AD6"
            MLB="00000000000GDVW00";;
        elcapitan|10.11)
            BOARD_ID="Mac-FFE5EF870D7BA81A"
            MLB="00000000000GQRX00";;
        sierra|10.12)
            BOARD_ID="Mac-77F17D7DA9285301"
            MLB="00000000000J0DX00";;
        high-sierra|10.13)
            BOARD_ID="Mac-BE088AF8C5EB4FA2"
            MLB="00000000000J80300";;
        mojave|10.14)
            BOARD_ID="Mac-7BA5B2DFE22DDD8C"
            MLB="00000000000KXPG00";;
        catalina|10.15)
            BOARD_ID="Mac-00BE6ED71E35EB86";;
        big-sur|11)
            BOARD_ID="Mac-42FD25EABCABB274";;
        monterey|12)
            BOARD_ID="Mac-E43C1C25D4880AD6";;
        ventura|13)
            BOARD_ID="Mac-BE088AF8C5EB4FA2";;
        sonoma|14)
            BOARD_ID="Mac-53FDB3D8DB8CA971";;
        *) echo "ERROR! Unknown release: ${RELEASE}"
           releases_macos
           exit 1;;
    esac

    CWD="$(dirname "${0}")"
    if [ -x "${CWD}/chunkcheck" ]; then
        CHUNKCHECK="${CWD}/chunkcheck"
    elif [ -x "$(command -v chunkcheck)" ]; then
        CHUNKCHECK="$(command -v chunkcheck)"
    fi

    appleSession=$(curl -v -H "Host: osrecovery.apple.com" \
                           -H "Connection: close" \
                           -A "InternetRecovery/1.0" http://osrecovery.apple.com/ 2>&1 | tr ';' '\n' | awk -F'session=|;' '{print $2}' | grep 1)
    info=$(curl -s -X POST -H "Host: osrecovery.apple.com" \
                           -H "Connection: close" \
                           -A "InternetRecovery/1.0" \
                           -b "session=\"${appleSession}\"" \
                           -H "Content-Type: text/plain" \
                           -d $'cid='"$(generate_id 16)"$'\nsn='${MLB}$'\nbid='${BOARD_ID}$'\nk='"$(generate_id 64)"$'\nfg='"$(generate_id 64)"$'\nos='${OS_TYPE} \
                           http://osrecovery.apple.com/InstallationPayload/RecoveryImage | tr ' ' '\n')
    downloadLink=$(echo "$info" | grep 'oscdn' | grep 'dmg')
    downloadSession=$(echo "$info" | grep 'expires' | grep 'dmg')
    chunkListLink=$(echo "$info" | grep 'oscdn' | grep 'chunklist')
    chunkListSession=$(echo "$info" | grep 'expires' | grep 'chunklist')

    if [ "${OPERATION}" == "show" ]; then
        test_result "${OS}" "${RELEASE}" "" "${downloadLink}"
        exit 0
    elif [ "${OPERATION}" == "test" ]; then
        CHECK=$(web_check "${downloadLink}" --header "Host: oscdn.apple.com" --header "Connection: close" --header "User-Agent: InternetRecovery/1.0" --header "Cookie: AssetToken=${downloadSession}" && echo "PASS" || echo "FAIL")
        test_result "${OS}" "${RELEASE}" "" "${downloadLink}" "${CHECK}"
        exit 0
    elif [ "${OPERATION}" == "download" ]; then
        echo "Downloading macOS (${RELEASE^}) RecoveryImage"
        echo " - URL: ${downloadLink}"
        web_get "${downloadLink}" "${VM_PATH}" RecoveryImage.dmg --header "Host: oscdn.apple.com" --header "Connection: close" --header "User-Agent: InternetRecovery/1.0" --header "Cookie: AssetToken=${downloadSession}"
        web_get "${chunkListLink}" "${VM_PATH}" RecoveryImage.chunklist --header "Host: oscdn.apple.com" --header "Connection: close" --header "User-Agent: InternetRecovery/1.0" --header "Cookie: AssetToken=${chunkListSession}"
        VM_PATH="$(pwd)"
    else
        if [ ! -e "${VM_PATH}/RecoveryImage.chunklist" ]; then
            echo "Downloading macOS (${RELEASE^}) RecoveryImage"
            echo " - URL: ${downloadLink}"
            web_get "${downloadLink}" "${VM_PATH}" RecoveryImage.dmg --header "Host: oscdn.apple.com" --header "Connection: close" --header "User-Agent: InternetRecovery/1.0" --header "Cookie: AssetToken=${downloadSession}"
            web_get "${chunkListLink}" "${VM_PATH}" RecoveryImage.chunklist --header "Host: oscdn.apple.com" --header "Connection: close" --header "User-Agent: InternetRecovery/1.0" --header "Cookie: AssetToken=${chunkListSession}"
            if ! "${CHUNKCHECK}" "${VM_PATH}" 2> /dev/null; then
                echo " - WARNING! Verification failed, continuing anyway"
            else
                echo " - Verification passed"
            fi

            if [ -e "${VM_PATH}/RecoveryImage.dmg" ] && [ ! -e "${VM_PATH}/RecoveryImage.img" ]; then
                echo " - Converting RecoveryImage.dmg"
                ${QEMU_IMG} convert "${VM_PATH}/RecoveryImage.dmg" -O raw "${VM_PATH}/RecoveryImage.img" 2>/dev/null
            fi
            rm "${VM_PATH}/RecoveryImage.dmg" "${VM_PATH}/RecoveryImage.chunklist"
            echo " - RecoveryImage.img is ready."
        fi
        echo "Downloading OpenCore & UEFI firmware"
        web_get "https://mirror.ghproxy.com/github.com/kholia/OSX-KVM/raw/master/OpenCore/OpenCore.qcow2" "${VM_PATH}"
        web_get "https://mirror.ghproxy.com/github.com/kholia/OSX-KVM/raw/master/OVMF_CODE.fd" "${VM_PATH}"
        if [ ! -e "${VM_PATH}/OVMF_VARS-1920x1080.fd" ]; then
            web_get "https://mirror.ghproxy.com/github.com/kholia/OSX-KVM/raw/master/OVMF_VARS-1920x1080.fd" "${VM_PATH}"
        fi
    fi
    make_vm_config RecoveryImage.img
}

function get_mageia() {
    local HASH=""
    local ISO=""
    ISO=$(web_pipe https://www.mageia.org/en/downloads/get/?q="Mageia-${RELEASE}-Live-${EDITION}-x86_64.iso" | grep 'click here'| grep -o 'href=.*\.iso'|cut -d\" -f2)
    HASH=$(web_pipe "${ISO}.sha512" | cut -d' ' -f1)
    echo "${ISO} ${HASH}"
}

function get_manjaro() {
    local HASH=""
    local ISO=""
    local MANIFEST=""
    local URL=""
    local TYPE="official"
    MANIFEST="$(web_pipe https://gitlab.manjaro.org/web/iso-info/-/raw/master/file-info.json)"
    case "${RELEASE}" in
        sway)
            MANIFEST="$(web_pipe https://mirror.manjaro-sway.download/manjaro-sway/release.json)"
            TYPE="sway"
            ;;
        cinnamon|i3) TYPE="community";;
    esac

    if [ "${EDITION}" == "minimal" ] && [ "${TYPE}" != "sway" ]; then
        EDITION=".minimal"
    else
        EDITION=""
    fi

    if [ "${RELEASE}" == "sway" ]; then
        URL=$(echo "${MANIFEST}" | jq -r '.[] | select(.name|test("^manjaro-sway-.*[.]iso$")) | .url')
    else
        URL="$(echo "${MANIFEST}" | jq -r ."${TYPE}.${RELEASE}${EDITION}".image)"
    fi
    HASH=$(web_pipe "${URL}.sha512" | cut -d' ' -f1)
    echo "${URL} ${HASH}"
}

function get_mxlinux() {
    local HASH=""
    local ISO=""
    local URL="https://sourceforge.net/projects/mx-linux/files/Final/${EDITION}"
    case ${EDITION} in
        Xfce) ISO="MX-${RELEASE}_x64.iso";;
        KDE) ISO="MX-${RELEASE}_KDE_x64.iso";;
        Fluxbox) ISO="MX-${RELEASE}_fluxbox_x64.iso";;
    esac
    HASH=$(web_pipe "${URL}/${ISO}.sha256" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_netboot() {
    local HASH=""
    local ISO="netboot.xyz.iso"
    local URL="https://boot.netboot.xyz/ipxe"
    HASH=$(web_pipe "${URL}/netboot.xyz-sha256-checksums.txt" | grep "${ISO}" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_netbsd() {
    local HASH=""
    local ISO="NetBSD-${RELEASE}-amd64.iso"
    local URL="https://cdn.netbsd.org/pub/NetBSD/NetBSD-${RELEASE}/images"
    HASH=$(web_pipe "${URL}/MD5" | grep "${ISO}" | cut -d' ' -f4)
    echo "${URL}/${ISO} ${HASH}"
}

function get_nitrux() {
    local HASH=""
    local URLBASE=""
    local URL=""
    local ISO=""
    URLBASE="https://sourceforge.net/projects/nitruxos/files/Release"
    URL="${URLBASE}/ISO"
    ISO=$(web_pipe 'https://sourceforge.net/projects/nitruxos/rss?path=/Release/ISO' | grep '.iso' | head -n 1 | cut -d']' -f1 | cut -d '/' -f4)
    HASH=$(web_pipe "${URLBASE}/MD5/${ISONAME}.md5sum" | grep "${ISO}" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_nixos() {
    local HASH=""
    # Adapt the plasma edition according to the NixOS release
    case "${EDITION}" in
        plasma)
            if [ "${RELEASE}" == "23.11" ]; then
                EDITION+="5"
            else
                EDITION+="6"
            fi
            ;;
    esac
    local ISO="latest-nixos-${EDITION}-x86_64-linux.iso"
    local URL="https://channels.nixos.org/nixos-${RELEASE}"
    HASH=$(web_pipe "${URL}/${ISO}.sha256" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_nwg-shell() {
    local HASH=""
    local ISO="nwg-live-${RELEASE}-x86_64.iso"
    local URL="https://sourceforge.net/projects/nwg-iso/files"
    HASH="$(web_pipe "https://sourceforge.net/projects/nwg-iso/rss?path=/" | grep "${ISO}" | cut -d'>' -f3 | cut -d'<' -f1 | tail -n 1)"
    echo "${URL}/${ISO} ${HASH}"
}

function get_openbsd() {
    local HASH=""
    local ISO="install${RELEASE//\./}.iso"
    local URL="https://mirror.leaseweb.com/pub/OpenBSD/${RELEASE}/amd64"
    HASH=$(web_pipe "${URL}/SHA256" | grep "${ISO}" | cut -d' ' -f4)
    echo "${URL}/${ISO} ${HASH}"
}

function get_openindiana() {
    local HASH=""
    local ISO=""
    local URL=""
    URL="https://dlc.openindiana.org/isos/hipster/${RELEASE}"
    ISO="OI-hipster-${EDITION}-${RELEASE}.iso"
    HASH=$(web_pipe "${URL}/${ISO}.sha256" |cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_opensuse() {
    local HASH=""
    local ISO=""
    local URL=""
    if [ "${RELEASE}" == "tumbleweed" ]; then
        ISO="openSUSE-Tumbleweed-DVD-x86_64-Current.iso"
        URL="https://download.opensuse.org/tumbleweed/iso"
    elif [ "${RELEASE}" == "microos" ]; then
        ISO="openSUSE-MicroOS-DVD-x86_64-Current.iso"
        URL="https://download.opensuse.org/tumbleweed/iso"
    elif [ "${RELEASE}" == 15.0 ] || [ "${RELEASE}" == 15.1 ]; then
        ISO="openSUSE-Leap-${RELEASE}-DVD-x86_64.iso"
        URL="https://download.opensuse.org/distribution/leap/${RELEASE}/iso"
    else
        ISO="openSUSE-Leap-${RELEASE}-DVD-x86_64-Current.iso"
        URL="https://download.opensuse.org/distribution/leap/${RELEASE}/iso"
    fi
    HASH=$(web_pipe "${URL}/${ISO}.sha256" | awk '{if(NR==4) print $0}' | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_oraclelinux() {
    local HASH=""
    local ISO=""
    local VER_MAJ=${RELEASE::1}
    local VER_MIN=${RELEASE:2:1}
    local URL="https://yum.oracle.com/ISOS/OracleLinux/OL${VER_MAJ}/u${VER_MIN}/x86_64"
    case ${VER_MAJ} in
        7) ISO="OracleLinux-R${VER_MAJ}-U${VER_MIN}-Server-x86_64-dvd.iso";;
        *) ISO="OracleLinux-R${VER_MAJ}-U${VER_MIN}-x86_64-dvd.iso";;
    esac
    HASH=$(web_pipe "https://linux.oracle.com/security/gpg/checksum/OracleLinux-R${VER_MAJ}-U${VER_MIN}-Server-x86_64.checksum" | grep "${ISO}" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_parrotsec() {
    local HASH=""
    local ISO=""
    local URL=""
    ISO="Parrot-${EDITION}-${RELEASE}_amd64.iso"
    URL="https://download.parrot.sh/parrot/iso/${RELEASE}"
    HASH="$(web_pipe "${URL}/signed-hashes.txt" | grep "${ISO}" | cut -d' ' -f1)"
    echo "${URL}/${ISO} ${HASH}"
}

function get_peppermint() {
    local HASH=""
    local ISO=""
    local URL="https://sourceforge.net/projects/peppermintos/files/isos"
    case ${EDITION} in
        devuan-xfce)
            ISO="PeppermintOS-devuan_64_xfce.iso"
            URL="${URL}/XFCE";;
        debian-xfce)
            ISO="PeppermintOS-Debian-64.iso"
            URL="${URL}/XFCE";;
        devuan-gnome)
            ISO="PeppermintOS-devuan_64_gfb.iso"
            URL="${URL}/Gnome_FlashBack";;
        debian-gnome)
            ISO="PeppermintOS-Debian_64_gfb.iso"
            URL="${URL}/Gnome_FlashBack";;
    esac
    HASH=$(web_pipe "${URL}/${ISO}-sha512.checksum" | grep "${ISO}" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_popos() {
    local HASH=""
    local ISO=""
    local URL=""
    URL=$(web_pipe "https://api.pop-os.org/builds/${RELEASE}/${EDITION}" | jq -r .url)
    HASH=$(web_pipe "https://api.pop-os.org/builds/${RELEASE}/${EDITION}" | jq -r .sha_sum)
    echo "${URL} ${HASH}"
}

function get_porteus() {
    local HASH=""
    local ISO=""
    local URL=""
    edition="${EDITION~~}"
    ISO="Porteus-${edition}-v${RELEASE}-x86_64.iso"
    URL="https://mirrors.dotsrc.org/porteus/x86_64/Porteus-v${RELEASE}"
    HASH=$(web_pipe "${URL}/sha256sums.txt" | grep "${ISO}" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_primtux() {
    local HASH=""
    local URL=""
    local ISO=""
    ISO="PrimTux${RELEASE}-amd64-${EDITION}.iso"
    URL="https://sourceforge.net/projects/primtux/files/Distribution"
    HASH=$(web_pipe "${URL}/${ISO}.md5" | grep "${ISO}" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_pureos() {
    local HASH=""
    local ISO=""
    local URL=""
    local PureName=
    PureName="$(web_pipe "https://www.pureos.net/download/" | grep -m 1 "downloads.puri" | cut -d '/' -f 4)"
    local PureDate=
    PureDate="$(web_pipe "https://www.pureos.net/download/" | grep -m 1 "downloads.puri" | cut -d '/' -f 6)"
    local PureDateSquashed="${PureDate//'-'/}"
    edition="${EDITION,,}"
    URL="https://downloads.puri.sm/${PureName}/${edition}/${PureDate}"
    ISO="pureos-${RELEASE}-${edition}-live-${PureDateSquashed}_amd64.iso"
    local IsoTrimmed=
    IsoTrimmed="${ISO%.*}"
    HASH="$(web_pipe "${URL}/${IsoTrimmed}.checksums_sha256.txt" | grep -m 1 '.iso' | cut -d '.' -f 1)"
    echo "${URL}/${ISO} ${HASH}"
}

function get_reactos() {
    local HASH=""
    local URL=""
    URL="$(web_redirect "https://sourceforge.net/projects/reactos/files/latest/download")"
    echo "${URL} ${HASH}"
}

function get_rebornos() {
    local HASH=""
    local ISO=""
    ISO=$(web_pipe "https://meta.cdn.soulharsh007.dev/RebornOS-ISO?format=json" | jq -r ".url")
    HASH=$(web_pipe "https://meta.cdn.soulharsh007.dev/RebornOS-ISO?format=json" | jq -r ".md5")
    echo "${ISO} ${HASH}"
}

function get_rockylinux() {
    if [[ "${RELEASE}" =~ ^8. ]] && [[ "${EDITION}" == "dvd" ]]; then
        EDITION="dvd1"
    fi
    local HASH=""
    local ISO="Rocky-${RELEASE}-x86_64-${EDITION}.iso"
    local URL=""
    URL="http://dl.rockylinux.org/vault/rocky/${RELEASE}/isos/x86_64"
    HASH=$(web_pipe "${URL}/CHECKSUM" | grep "SHA256" | grep "${ISO})" | cut -d' ' -f4)
    echo "${URL}/${ISO} ${HASH}"
}

function get_siduction() {
    local HASH=""
    local DATE=""
    local ISO=""
    local URL="https://mirrors.dotsrc.org/siduction/iso/Standing_on_the_Shoulders_of_Giants/${EDITION}"
    DATE=$(web_pipe "${URL}"| grep .iso.md5 | cut -d'-' -f6 | cut -d'.' -f1)
    HASH=$(web_pipe "${URL}/${ISO}.md5" | cut -d' ' -f1)
    ISO="siduction-2023.1.1-Standing_on_the_Shoulders_of_Giants-${EDITION}-amd64-${DATE}.iso"
    echo "${URL}/${ISO} ${HASH}"
}

function get_slackware() {
    local HASH=""
    local ISO="slackware64-${RELEASE}-install-dvd.iso"
    local URL="https://slackware.nl/slackware/slackware-iso/slackware64-${RELEASE}-iso"
    HASH=$(web_pipe "${URL}/${ISO}.md5" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_slax() {
    local HASH=""
    local ISO=""
    local URL=""
    case ${EDITION} in
        debian)
            URL="https://ftp.fi.muni.cz/pub/linux/slax/Slax-12.x"
            ISO=$(web_pipe "${URL}/md5.txt" | grep '64bit-' | cut -d' ' -f3 | tail -n1);;
        slackware)
            URL="https://ftp.fi.muni.cz/pub/linux/slax/Slax-15.x"
            ISO=$(web_pipe "${URL}/md5.txt" | grep '64bit-' | cut -d' ' -f3 | tail -n1);;
    esac
    HASH=$(web_pipe "${URL}/md5.txt" | grep '64bit-' | cut -d' ' -f1 | tail -n1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_slint() {
    local HASH=""
    local MAJ_VER=""
    local ISO="slint64-${RELEASE}.iso"
    MAJ_VER="$(echo "${RELEASE}" | cut -d'-' -f 1)"
    local URL="https://slackware.uk/slint/x86_64/slint-${MAJ_VER}/iso"
    HASH=$(web_pipe "${URL}/${ISO}.sha256" | cut -d' ' -f4)
    echo "${URL}/${ISO}" "${HASH}"
}

function get_slitaz() {
    local HASH=""
    local ISO="slitaz-rolling-${RELEASE}"
    local URL="http://mirror.slitaz.org/iso/rolling"
    HASH=$(web_pipe "${URL}/${ISO}.md5" | cut -d' ' -f1)
    echo "${URL}/${ISO}.iso ${HASH}"
}

function get_solus() {
    local HASH=""
    local ISO="Solus-${RELEASE}-${EDITION}.iso"
    local URL="https://downloads.getsol.us/isos/${RELEASE}"
    HASH=$(web_pipe "${URL}/${ISO}.sha256sum" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_sparkylinux() {
    local HASH=""
    local ISO=""
    local URL=""
    ISO="sparkylinux-${RELEASE}-x86_64-${EDITION}.iso"
    case ${EDITION} in
        minimalcli) URL="https://sourceforge.net/projects/sparkylinux/files/cli";;
        minimalgui) URL="https://sourceforge.net/projects/sparkylinux/files/base";;
        *) URL="https://sourceforge.net/projects/sparkylinux/files/${EDITION}";;
    esac
    HASH=$(web_pipe "${URL}/${ISO}.allsums.txt" | head -n 2 | grep 'iso' | cut -d' ' -f1)
    echo "${URL}/${ISO}" "${HASH}"
}

function get_spirallinux() {
    local HASH=""
    local ISO="SpiralLinux_${EDITION}_12.231005_x86-64.iso"
    local URL="https://sourceforge.net/projects/spirallinux/files/12.231005"
    HASH=$(web_pipe 'https://sourceforge.net/projects/spirallinux/rss?path=/' | grep "${ISO}" | grep 'md5' | cut -d'<' -f3 | cut -d'>' -f2)
    echo "${URL}/${ISO}" "${HASH}"
}

function get_tails() {
    local JSON=""
    local HASH=""
    local URL=""
    JSON="$(web_pipe "https://tails.boum.org/install/v2/Tails/amd64/${RELEASE}/latest.json")"
    URL=$(echo "${JSON}" | jq -r '.installations[0]."installation-paths"[]|select(.type=="iso")|."target-files"[0].url')
    HASH=$(echo "${JSON}" | jq -r '.installations[0]."installation-paths"[]|select(.type=="iso")|."target-files"[0].sha256')
    echo "${URL} ${HASH}"
}

function get_tinycore() {
    local ARCH="x86"
    local HASH=""
    local ISO="${EDITION}-${RELEASE}.0.iso"
    case "${EDITION}" in
        *Pure*) ARCH+="_64";;
    esac
    local URL="http://www.tinycorelinux.net/${RELEASE}.x/${ARCH}/release"
    HASH=$(web_pipe "${URL}/${ISO}.md5.txt" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_trisquel() {
    local HASH=""
    local ISO=""
    local URL="https://mirrors.ocf.berkeley.edu/trisquel-images"
    case ${EDITION} in
        mate) ISO="trisquel_${RELEASE}_amd64.iso";;
        lxde) ISO="trisquel-mini_${RELEASE}_amd64.iso";;
        kde) ISO="triskel_${RELEASE}_amd64.iso";;
        sugar) ISO="trisquel-sugar_${RELEASE}_amd64.iso";;
    esac
    HASH=$(web_pipe "${URL}/${ISO}.sha1" | grep "${ISO}" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_truenas-scale() {
    local HASH=""
    local ISO=""
    local URL=""
    local DLINFO="https://www.truenas.com/download-truenas-scale/"
    URL=$(web_pipe "${DLINFO}" | grep -o "\"https://.*${RELEASE}.*\.iso\"" | cut -d'"' -f 2)
    HASH=$(web_pipe "${URL}.sha256" | cut -d' ' -f1)
    echo "${URL} ${HASH}"
}

function get_truenas-core() {
    local ISO=""
    local URL=""
    local DLINFO="https://www.truenas.com/download-truenas-core/"
    URL=$(web_pipe "${DLINFO}" | grep -o "\"https://.*${RELEASE}.*\.iso\"" | cut -d'"' -f 2)
    HASH=$(web_pipe "${URL}".sha256 | cut -d' ' -f1)
    echo "${URL} ${HASH}"
}

function get_tuxedo-os() {
    local HASH=""
    local ISO=""
    local URL="https://os.tuxedocomputers.com"
    ISO="$(web_pipe "https://os.tuxedocomputers.com/" | grep -m 1 current.iso | cut -d '=' -f 4 | cut -d '"' -f 2)"
    HASH="$(web_pipe "https://os.tuxedocomputers.com/checksums/${ISO}.sha256" | cut -d ' ' -f 1)"
    echo "${URL}/${ISO} ${HASH}"
}

function get_ubuntu-server() {
    local HASH=""
    local ISO=""
    local NAME="live-server"
    local URL=""

    if [[ "${RELEASE}" == "daily"* ]]; then
        URL="https://cdimage.ubuntu.com/${OS}/${RELEASE}/current"
    else
        URL="https://releases.ubuntu.com/${RELEASE}"
    fi

    case "${RELEASE}" in
        14*|16*) NAME="server";;
    esac

    if web_check "${URL}/SHA256SUMS"; then
        DATA=$(web_pipe "${URL}/SHA256SUMS" | grep "${NAME}" | grep amd64 | grep iso)
        ISO=$(cut -d'*' -f2 <<<"${DATA}")
        HASH=$(cut -d' ' -f1 <<<"${DATA}")
    else
        DATA=$(web_pipe "${URL}/MD5SUMS" | grep "${NAME}" | grep amd64 | grep iso)
        ISO=$(cut -d' ' -f3 <<<"${DATA}")
        HASH=$(cut -d' ' -f1 <<<"${DATA}")
    fi
    if [[ "${RELEASE}" == "daily"* ]] || [ "${RELEASE}" == "dvd" ]; then
        zsync_get "${URL}/${ISO}" "${VM_PATH}" "${OS}-devel.iso"
        make_vm_config "${OS}-devel.iso"
    else
        web_get "${URL}/${ISO}" "${VM_PATH}"
        check_hash "${ISO}" "${HASH}"
        make_vm_config "${ISO}"
    fi
}

function get_ubuntu() {
    local ISO=""
    local HASH=""
    local URL=""
    local DATA=""

    if [[ "${RELEASE}" == "daily"* ]] && [ "${OS}" == "ubuntustudio" ]; then
        # Ubuntu Studio daily-live images are in the dvd directory
        RELEASE="dvd"
    fi
    if [[ "${RELEASE}" == "jammy-daily" ]]; then
        if [[ "${OS}" == "ubuntustudio" ]]; then
            URL="https://cdimage.ubuntu.com/${OS}/jammy/dvd/current"
        else
            URL="https://cdimage.ubuntu.com/${OS}/jammy/daily-live/current"
        fi
        VM_PATH="${OS}-jammy-live"
    elif [[ "${RELEASE}" == "daily"* ]] || [ "${RELEASE}" == "dvd" ]; then
        URL="https://cdimage.ubuntu.com/${OS}/${RELEASE}/current"
        VM_PATH="${OS}-${RELEASE}"
    elif [ "${OS}" == "ubuntu" ]; then
        URL="https://releases.ubuntu.com/${RELEASE}"
    else
        URL="https://cdimage.ubuntu.com/${OS}/releases/${RELEASE}/release"
    fi
    if web_check "${URL}/SHA256SUMS"; then
        DATA=$(web_pipe "${URL}/SHA256SUMS" | grep 'desktop\|dvd\|install' | grep amd64 | grep iso | grep -v "+mac")
        ISO=$(cut -d'*' -f2 <<<"${DATA}" | sed '1q;d')
        HASH=$(cut -d' ' -f1 <<<"${DATA}" | sed '1q;d')
    else
        DATA=$(web_pipe "${URL}/MD5SUMS" | grep 'desktop\|dvd\|install' | grep amd64 | grep iso | grep -v "+mac")
        ISO=$(cut -d'*' -f2 <<<"${DATA}")
        HASH=$(cut -d' ' -f1 <<<"${DATA}")
    fi
    if [ -z "${ISO}" ] || [ -z "${HASH}" ]; then
        echo "$(pretty_name "${OS}") ${RELEASE} is currently unavailable. Please select other OS/Release combination"
        exit 1
    fi
    if [[ "${RELEASE}" == "daily"* ]] || [ "${RELEASE}" == "dvd" ]; then
        zsync_get "${URL}/${ISO}" "${VM_PATH}" "${OS}-devel.iso"
        make_vm_config "${OS}-devel.iso"
    elif [[ "${RELEASE}" == "jammy-daily" ]]; then
        zsync_get "${URL}/${ISO}" "${VM_PATH}" "${OS}-jammy-live.iso"
        make_vm_config "${OS}-jammy-live.iso"
    else
        web_get "${URL}/${ISO}" "${VM_PATH}"
        check_hash "${ISO}" "${HASH}"
        make_vm_config "${ISO}"
    fi
}

function get_vanillaos() {
    local HASH=""
    local HASH_URL=""
    local ISO=""
    ISO=$(web_pipe "https://api.github.com/repos/Vanilla-OS/live-iso/releases" | grep 'download_url' | grep "${RELEASE}" | head -n 1 | cut -d'"' -f4)
    HASH_URL="${ISO//.iso/.sha256.txt}"
    HASH=$(web_pipe "${HASH_URL}" | cut -d' ' -f1)
    echo "${ISO} ${HASH}"
}

function get_void() {
    local DATE=""
    local HASH=""
    local ISO=""
    local URL="https://repo-default.voidlinux.org/live"
    case ${EDITION} in
        glibc) ISO="void-live-x86_64-${RELEASE}-base.iso";;
        musl) ISO="void-live-x86_64-musl-${RELEASE}-base.iso";;
        xfce-glibc) ISO="void-live-x86_64-${RELEASE}-xfce.iso";;
        xfce-musl) ISO="void-live-x86_64-musl-${RELEASE}-xfce.iso";;
    esac
    HASH="$(web_pipe "${URL}/sha256sum.txt" | grep "${ISO}" | cut -d' ' -f4)"
    echo "${URL}/${RELEASE}/${ISO} ${HASH}"
}

function get_vxlinux() {
    local HASH=""
    local ISO="vx-${RELEASE}.iso"
    local URL="https://github.com/VX-Linux/main/releases/download/${RELEASE}"
    HASH=$(web_pipe "${URL}/vx-${RELEASE}.md5" | cut -d' ' -f1)
    echo "${URL}/${ISO} ${HASH}"
}

function get_zorin() {
    local HASH=""
    local ISO=""
    local URL=""
    # Process the URL redirections; required for Zorin
    URL=$(web_redirect "https://zrn.co/${RELEASE}${EDITION}")
    echo "${URL} ${HASH}"
}

function unattended_windows() {
    cat << 'EOF' > "${1}"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend"
  xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <!--
       For documentation on components:
       https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/
  -->
  <settings pass="offlineServicing">
    <component name="Microsoft-Windows-LUA-Settings" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <EnableLUA>false</EnableLUA>
    </component>
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <ComputerName>*</ComputerName>
    </component>
  </settings>

  <settings pass="generalize">
    <component name="Microsoft-Windows-PnPSysprep" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
      <PersistAllDeviceInstalls>true</PersistAllDeviceInstalls>
    </component>
    <component name="Microsoft-Windows-Security-SPP" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <SkipRearm>1</SkipRearm>
    </component>
  </settings>

  <settings pass="specialize">
    <component name="Microsoft-Windows-Security-SPP-UX" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <SkipAutoActivation>true</SkipAutoActivation>
    </component>
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <ComputerName>*</ComputerName>
      <OEMInformation>
        <Manufacturer>Quickemu Project</Manufacturer>
        <Model>Quickemu</Model>
        <SupportHours>24/7</SupportHours>
        <SupportPhone></SupportPhone>
        <SupportProvider>Quickemu Project</SupportProvider>
        <SupportURL>https://github.com/quickemu-project/quickemu/issues</SupportURL>
      </OEMInformation>
      <OEMName>Quickemu Project</OEMName>
      <ProductKey>W269N-WFGWX-YVC9B-4J6C9-T83GX</ProductKey>
    </component>
    <component name="Microsoft-Windows-SQMApi" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <CEIPEnabled>0</CEIPEnabled>
    </component>
  </settings>

  <settings pass="windowsPE">
    <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <Diagnostics>
        <OptIn>false</OptIn>
      </Diagnostics>
      <DiskConfiguration>
        <Disk wcm:action="add">
          <DiskID>0</DiskID>
          <WillWipeDisk>true</WillWipeDisk>
          <CreatePartitions>
            <!-- Windows RE Tools partition -->
            <CreatePartition wcm:action="add">
              <Order>1</Order>
              <Type>Primary</Type>
              <Size>256</Size>
            </CreatePartition>
            <!-- System partition (ESP) -->
            <CreatePartition wcm:action="add">
              <Order>2</Order>
              <Type>EFI</Type>
              <Size>128</Size>
            </CreatePartition>
            <!-- Microsoft reserved partition (MSR) -->
            <CreatePartition wcm:action="add">
              <Order>3</Order>
              <Type>MSR</Type>
              <Size>128</Size>
            </CreatePartition>
            <!-- Windows partition -->
            <CreatePartition wcm:action="add">
              <Order>4</Order>
              <Type>Primary</Type>
              <Extend>true</Extend>
            </CreatePartition>
          </CreatePartitions>
          <ModifyPartitions>
            <!-- Windows RE Tools partition -->
            <ModifyPartition wcm:action="add">
              <Order>1</Order>
              <PartitionID>1</PartitionID>
              <Label>WINRE</Label>
              <Format>NTFS</Format>
              <TypeID>DE94BBA4-06D1-4D40-A16A-BFD50179D6AC</TypeID>
            </ModifyPartition>
            <!-- System partition (ESP) -->
            <ModifyPartition wcm:action="add">
              <Order>2</Order>
              <PartitionID>2</PartitionID>
              <Label>System</Label>
              <Format>FAT32</Format>
            </ModifyPartition>
            <!-- MSR partition does not need to be modified -->
            <ModifyPartition wcm:action="add">
              <Order>3</Order>
              <PartitionID>3</PartitionID>
            </ModifyPartition>
            <!-- Windows partition -->
              <ModifyPartition wcm:action="add">
              <Order>4</Order>
              <PartitionID>4</PartitionID>
              <Label>Windows</Label>
              <Letter>C</Letter>
              <Format>NTFS</Format>
            </ModifyPartition>
          </ModifyPartitions>
        </Disk>
      </DiskConfiguration>
      <DynamicUpdate>
        <Enable>true</Enable>
        <WillShowUI>Never</WillShowUI>
      </DynamicUpdate>
      <ImageInstall>
        <OSImage>
          <InstallTo>
            <DiskID>0</DiskID>
            <PartitionID>4</PartitionID>
          </InstallTo>
          <InstallToAvailablePartition>false</InstallToAvailablePartition>
        </OSImage>
      </ImageInstall>
      <RunSynchronous>
        <RunSynchronousCommand wcm:action="add">
          <Order>1</Order>
          <Path>reg add HKLM\System\Setup\LabConfig /v BypassCPUCheck /t REG_DWORD /d 0x00000001 /f</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>2</Order>
          <Path>reg add HKLM\System\Setup\LabConfig /v BypassRAMCheck /t REG_DWORD /d 0x00000001 /f</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>3</Order>
          <Path>reg add HKLM\System\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 0x00000001 /f</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>4</Order>
          <Path>reg add HKLM\System\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 0x00000001 /f</Path>
        </RunSynchronousCommand>
      </RunSynchronous>
      <UpgradeData>
        <Upgrade>false</Upgrade>
        <WillShowUI>Never</WillShowUI>
      </UpgradeData>
      <UserData>
        <AcceptEula>true</AcceptEula>
        <FullName>Quickemu</FullName>
        <Organization>Quickemu Project</Organization>
        <!-- https://docs.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys -->
        <ProductKey>
          <Key>W269N-WFGWX-YVC9B-4J6C9-T83GX</Key>
          <WillShowUI>Never</WillShowUI>
        </ProductKey>
      </UserData>
    </component>

    <component name="Microsoft-Windows-PnpCustomizationsWinPE" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" processorArchitecture="amd64" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <!--
           This makes the VirtIO drivers available to Windows, assuming that
           the VirtIO driver disk is available as drive E:
           https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md
      -->
      <DriverPaths>
        <PathAndCredentials wcm:action="add" wcm:keyValue="1">
          <Path>E:\qemufwcfg\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="2">
          <Path>E:\vioinput\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="3">
          <Path>E:\vioscsi\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="4">
          <Path>E:\viostor\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="5">
          <Path>E:\vioserial\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="6">
          <Path>E:\qxldod\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="7">
          <Path>E:\amd64\w10</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="8">
          <Path>E:\viogpudo\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="9">
          <Path>E:\viorng\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="10">
          <Path>E:\NetKVM\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="11">
          <Path>E:\viofs\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="12">
          <Path>E:\Balloon\w10\amd64</Path>
        </PathAndCredentials>
      </DriverPaths>
    </component>
  </settings>

  <settings pass="oobeSystem">
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <AutoLogon>
        <Password>
          <Value>quickemu</Value>
          <PlainText>true</PlainText>
        </Password>
        <Enabled>true</Enabled>
        <Username>Quickemu</Username>
      </AutoLogon>
      <DisableAutoDaylightTimeSet>false</DisableAutoDaylightTimeSet>
      <OOBE>
        <HideEULAPage>true</HideEULAPage>
        <HideLocalAccountScreen>true</HideLocalAccountScreen>
        <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
        <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
        <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
        <NetworkLocation>Home</NetworkLocation>
        <ProtectYourPC>3</ProtectYourPC>
        <SkipUserOOBE>true</SkipUserOOBE>
        <SkipMachineOOBE>true</SkipMachineOOBE>
        <VMModeOptimizations>
          <SkipWinREInitialization>true</SkipWinREInitialization>
        </VMModeOptimizations>
      </OOBE>
      <UserAccounts>
        <LocalAccounts>
          <LocalAccount wcm:action="add">
            <Password>
              <Value>quickemu</Value>
              <PlainText>true</PlainText>
            </Password>
            <Description>Quickemu</Description>
            <DisplayName>Quickemu</DisplayName>
            <Group>Administrators</Group>
            <Name>Quickemu</Name>
          </LocalAccount>
        </LocalAccounts>
      </UserAccounts>
      <RegisteredOrganization>Quickemu Project</RegisteredOrganization>
      <RegisteredOwner>Quickemu</RegisteredOwner>
      <FirstLogonCommands>
        <SynchronousCommand wcm:action="add">
          <CommandLine>msiexec /i E:\guest-agent\qemu-ga-x86_64.msi /quiet /passive /qn</CommandLine>
          <Description>Install Virtio Guest Agent</Description>
          <Order>1</Order>
        </SynchronousCommand>
        <SynchronousCommand wcm:action="add">
          <CommandLine>msiexec /i F:\spice-webdavd-x64-latest.msi /quiet /passive /qn</CommandLine>
          <Description>Install spice-webdavd file sharing agent</Description>
          <Order>2</Order>
        </SynchronousCommand>
        <SynchronousCommand wcm:action="add">
          <CommandLine>msiexec /i F:\UsbDk_1.0.22_x64.msi /quiet /passive /qn</CommandLine>
          <Description>Install usbdk USB sharing agent</Description>
          <Order>3</Order>
        </SynchronousCommand>
        <SynchronousCommand wcm:action="add">
          <CommandLine>msiexec /i F:\spice-vdagent-x64-0.10.0.msi /quiet /passive /qn</CommandLine>
          <Description>Install spice-vdagent SPICE agent</Description>
          <Order>4</Order>
        </SynchronousCommand>
        <SynchronousCommand wcm:action="add">
          <CommandLine>Cmd /c POWERCFG -H OFF</CommandLine>
          <Description>Disable Hibernation</Description>
          <Order>5</Order>
        </SynchronousCommand>
      </FirstLogonCommands>
    </component>
  </settings>
</unattend>
EOF
}

function handle_curl_error() {
    local error_code="$1"
    local fatal_error_action=2
    case "$error_code" in
        6)
            echo "Failed to resolve Microsoft servers! Is there an Internet connection? Exiting..."
            return "$fatal_error_action"
            ;;
        7)
            echo "Failed to contact Microsoft servers! Is there an Internet connection or is the server down?"
            ;;
        8)
            echo "Microsoft servers returned a malformed HTTP response!"
            ;;
        22)
            echo "Microsoft servers returned a failing HTTP status code!"
            ;;
        23)
            echo "Failed at writing Windows media to disk! Out of disk space or permission error? Exiting..."
            return "$fatal_error_action"
            ;;
        26)
            echo "Ran out of memory during download! Exiting..."
            return "$fatal_error_action"
            ;;
        36)
            echo "Failed to continue earlier download!"
            ;;
        63)
            echo "Microsoft servers returned an unexpectedly large response!"
            ;;
            # POSIX defines exit statuses 1-125 as usable by us
            # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_08_02
            $((error_code <= 125)))
            # Must be some other server or network error (possibly with this specific request/file)
            # This is when accounting for all possible errors in the curl manual assuming a correctly formed curl command and an HTTP(S) request, using only the curl features we're using, and a sane build
            echo "Miscellaneous server or network error!"
            ;;
        126 | 127 )
            echo "Curl command not found! Please install curl and try again. Exiting..."
            return "$fatal_error_action"
            ;;
        # Exit statuses are undefined by POSIX beyond this point
        *)
            case "$(kill -l "$error_code")" in
            # Signals defined to exist by POSIX:
            # https://pubs.opengroup.org/onlinepubs/009695399/basedefs/signal.h.html
            INT)
                echo "Curl was interrupted!"
                ;;
            # There could be other signals but these are most common
            SEGV | ABRT )
                echo "Curl crashed! Failed exploitation attempt? Please report any core dumps to curl developers. Exiting..."
                return "$fatal_error_action"
                ;;
            *)
                echo "Curl terminated due to a fatal signal!"
                ;;
            esac
    esac
    return 1
}

function download_windows_server() {
    local iso_download_page_html=""
    # Copyright (C) 2024 Elliot Killick <contact@elliotkillick.com>
    # This function is adapted from the Mido project:
    # https://github.com/ElliotKillick/Mido

    # Download enterprise evaluation Windows versions
    local windows_version="$1"
    local enterprise_type="$2"
    local PRETTY_RELEASE=""

    case "${RELEASE}" in
        *) PRETTY_RELEASE="${RELEASE}";;
    esac

    echo "Downloading $(pretty_name "${OS}") ${PRETTY_RELEASE} (${I18N})"

    local url="https://www.microsoft.com/en-us/evalcenter/download-$windows_version"

    echo " - Parsing download page: ${url}"
    iso_download_page_html="$(curl --silent --location --max-filesize 1M --fail --proto =https --tlsv1.2 --http1.1 -- "$url")" || {
        handle_curl_error $?
        return $?
    }

    if ! [ "$iso_download_page_html" ]; then
        # This should only happen if there's been some change to where this download page is located
        echo " - Windows server download page gave us an empty response"
        return 1
    fi

    local CULTURE=""
    local COUNTRY=""
    case "${I18N}" in
        "English (Great Britain)")
            CULTURE="en-gb"
            COUNTRY="GB";;
        "Chinese (Simplified)")
            CULTURE="zh-cn"
            COUNTRY="CN";;
        "Chinese (Traditional)")
            CULTURE="zh-tw"
            COUNTRY="TW";;
        "French")
            CULTURE="fr-fr"
            COUNTRY="FR";;
        "German")
            CULTURE="de-de"
            COUNTRY="DE";;
        "Italian")
            CULTURE="it-it"
            COUNTRY="IT";;
        "Japanese")
            CULTURE="ja-jp"
            COUNTRY="JP";;
        "Korean")
            CULTURE="ko-kr"
            COUNTRY="KR";;
        "Portuguese (Brazil)")
            CULTURE="pt-br"
            COUNTRY="BR";;
        "Spanish")
            CULTURE="es-es"
            COUNTRY="ES";;
        "Russian")
            CULTURE="ru-ru"
            COUNTRY="RU";;
        *)
            CULTURE="en-us"
            COUNTRY="US";;
    esac

    echo " - Getting download link.."
    iso_download_links="$(echo "$iso_download_page_html" | grep -o "https://go.microsoft.com/fwlink/p/?LinkID=[0-9]\+&clcid=0x[0-9a-z]\+&culture=${CULTURE}&country=${COUNTRY}")" || {
        # This should only happen if there's been some change to the download endpoint web address
        echo " - Windows server download page gave us no download link"
        return 1
    }

    # Limit untrusted size for input validation
    iso_download_links="$(echo "$iso_download_links" | head -c 1024)"

    case "$enterprise_type" in
        # Select x64 download link
        "enterprise") iso_download_link=$(echo "$iso_download_links" | head -n 2 | tail -n 1) ;;
        # Select x64 LTSC download link
        "ltsc") iso_download_link=$(echo "$iso_download_links" | head -n 4 | tail -n 1) ;;
        *) iso_download_link="$iso_download_links" ;;
    esac

    # Follow redirect so proceeding log message is useful
    # This is a request we make this Fido doesn't
    # We don't need to set "--max-filesize" here because this is a HEAD request and the output is to /dev/null anyway
    iso_download_link="$(curl --silent --location --output /dev/null --silent --write-out "%{url_effective}" --head --fail --proto =https --tlsv1.2 --http1.1 -- "$iso_download_link")" || {
        # This should only happen if the Microsoft servers are down
        handle_curl_error $?
        return $?
    }

    # Limit untrusted size for input validation
    iso_download_link="$(echo "$iso_download_link" | head -c 1024)"

    echo " - URL: $iso_download_link"

    # Download ISO
    FILE_NAME="${iso_download_link##*/}"
    web_get "${iso_download_link}" "${VM_PATH}" "${FILE_NAME}"
    OS="windows-server"
}

function download_windows_workstation() {
    local HASH=""
    local session_id=""
    local iso_download_page_html=""
    local product_edition_id=""
    local language_skuid_table_html=""
    local sku_id=""
    local iso_download_link_html=""
    local iso_download_link=""

    echo "Downloading Windows ${RELEASE} (${I18N})"
    # This function is adapted from the Mido project:
    # https://github.com/ElliotKillick/Mido
    # Download newer consumer Windows versions from behind gated Microsoft API

    # Either 10, or 11
    local windows_version="$1"

    local url="https://www.microsoft.com/en-us/software-download/windows$windows_version"
    case "$windows_version" in
        10) url="${url}ISO";;
    esac

    local user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:100.0) Gecko/20100101 Firefox/100.0"
    session_id="$(uuidgen)"

    # Get product edition ID for latest release of given Windows version
    # Product edition ID: This specifies both the Windows release (e.g. 22H2) and edition ("multi-edition" is default, either Home/Pro/Edu/etc., we select "Pro" in the answer files) in one number
    # This is the *only* request we make that Fido doesn't. Fido manually maintains a list of all the Windows release/edition product edition IDs in its script (see: $WindowsVersions array). This is helpful for downloading older releases (e.g. Windows 10 1909, 21H1, etc.) but we always want to get the newest release which is why we get this value dynamically
    # Also, keeping a "$WindowsVersions" array like Fido does would be way too much of a maintenance burden
    # Remove "Accept" header that curl sends by default
    echo " - Parsing download page: ${url}"
    iso_download_page_html="$(curl --silent --user-agent "$user_agent" --header "Accept:" --max-filesize 1M --fail --proto =https --tlsv1.2 --http1.1 -- "$url")" || {
        handle_curl_error $?
        return $?
    }

    echo -n " - Getting Product edition ID: "
    # tr: Filter for only numerics to prevent HTTP parameter injection
    # head -c was recently added to POSIX: https://austingroupbugs.net/view.php?id=407
    product_edition_id="$(echo "$iso_download_page_html" | grep -Eo '<option value="[0-9]+">Windows' | cut -d '"' -f 2 | head -n 1 | tr -cd '0-9' | head -c 16)"
    echo "$product_edition_id"

    echo " - Permit Session ID: $session_id"
    # Permit Session ID
    # "org_id" is always the same value
    curl --silent --output /dev/null --user-agent "$user_agent" --header "Accept:" --max-filesize 100K --fail --proto =https --tlsv1.2 --http1.1 -- "https://vlscppe.microsoft.com/tags?org_id=y6jn8c31&session_id=$session_id" || {
        # This should only happen if there's been some change to how this API works
        handle_curl_error $?
        return $?
    }

    # Extract everything after the last slash
    local url_segment_parameter="${url##*/}"

    echo -n " - Getting language SKU ID: "
    # Get language -> skuID association table
    # SKU ID: This specifies the language of the ISO. We always use "English (United States)", however, the SKU for this changes with each Windows release
    # We must make this request so our next one will be allowed
    # --data "" is required otherwise no "Content-Length" header will be sent causing HTTP response "411 Length Required"
    language_skuid_table_html="$(curl --silent --request POST --user-agent "$user_agent" --data "" --header "Accept:" --max-filesize 10K --fail --proto =https --tlsv1.2 --http1.1 -- "https://www.microsoft.com/en-US/api/controls/contentinclude/html?pageId=a8f8f489-4c7f-463a-9ca6-5cff94d8d041&host=www.microsoft.com&segments=software-download,$url_segment_parameter&query=&action=getskuinformationbyproductedition&sessionId=$session_id&productEditionId=$product_edition_id&sdVersion=2")" || {
        handle_curl_error $?
        return $?
    }

    # Limit untrusted size for input validation
    language_skuid_table_html="$(echo "$language_skuid_table_html" | head -c 10240)"

    # tr: Filter for only alphanumerics or "-" to prevent HTTP parameter injection
    sku_id="$(echo "$language_skuid_table_html" | grep "${I18N}" | sed 's/&quot;//g' | cut -d ',' -f 1  | cut -d ':' -f 2 | tr -cd '[:alnum:]-' | head -c 16)"
    echo "$sku_id"

    echo " - Getting ISO download link..."
    # Get ISO download link
    # If any request is going to be blocked by Microsoft it's always this last one (the previous requests always seem to succeed)
    # --referer: Required by Microsoft servers to allow request
    iso_download_link_html="$(curl --silent --request POST --user-agent "$user_agent" --data "" --referer "$url" --header "Accept:" --max-filesize 100K --fail --proto =https --tlsv1.2 --http1.1 -- "https://www.microsoft.com/en-US/api/controls/contentinclude/html?pageId=6e2a1789-ef16-4f27-a296-74ef7ef5d96b&host=www.microsoft.com&segments=software-download,$url_segment_parameter&query=&action=GetProductDownloadLinksBySku&sessionId=$session_id&skuId=$sku_id&language=English&sdVersion=2")"

    local failed=0

    if ! [ "$iso_download_link_html" ]; then
        # This should only happen if there's been some change to how this API works
        echo " - Microsoft servers gave us an empty response to our request for an automated download."
        failed=1
    fi

    if echo "$iso_download_link_html" | grep -q "We are unable to complete your request at this time."; then
        echo " - WARNING! Microsoft blocked the automated download request based on your IP address."
        failed=1
    fi

    if [ ${failed} -eq 1 ]; then
        echo "   Manually download the Windows ${windows_version} ISO using a web browser from: ${url}"
        echo "   Save the downloaded ISO to: $(realpath "${VM_PATH}")"
        echo "   Update the config file to reference the downloaded ISO: ./${VM_PATH}.conf"
        echo "   Continuing with the VM creation process..."
        return 1
    fi

    # Filter for 64-bit ISO download URL
    # sed: HTML decode "&" character
    # tr: Filter for only alphanumerics or punctuation
    iso_download_link="$(echo "$iso_download_link_html" | grep -o "https://software.download.prss.microsoft.com.*IsoX64" | cut -d '"' -f 1 | sed 's/&amp;/\&/g' | tr -cd '[:alnum:][:punct:]')"

    if ! [ "$iso_download_link" ]; then
        # This should only happen if there's been some change to the download endpoint web address
        echo " - Microsoft servers gave us no download link to our request for an automated download. Please manually download this ISO in a web browser: $url"
        return 1
    fi

    echo " - URL: ${iso_download_link%%\?*}"

    # Download ISO
    FILE_NAME="$(echo "$iso_download_link" | cut -d'?' -f1 | cut -d'/' -f5)"
    web_get "${iso_download_link}" "${VM_PATH}" "${FILE_NAME}"
}

function get_windows() {
    if [ "${OS}" == "windows-server" ]; then
        download_windows_server "windows-server-${RELEASE}"
    else
        if [ -e ~/qemu/windows-"${RELEASE}"-Chinese-Simplified/windows-"${RELEASE}".iso ]; then
            echo "使用自定义iso安装"
        else
            download_windows_workstation "${RELEASE}"
        fi
    fi

    if [ "${OPERATION}" == "download" ]; then
        exit 0
    fi

    echo "Downloading VirtIO drivers..."
    web_get "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso" "${VM_PATH}"

    rm -f "${VM_PATH}/unattended.iso"
    case ${RELEASE} in
        10|11)
            mkdir -p "${VM_PATH}/unattended" 2>/dev/null
            web_get https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x64-latest.msi "${VM_PATH}/unattended"
            web_get https://www.spice-space.org/download/windows/vdagent/vdagent-win-0.10.0/spice-vdagent-x64-0.10.0.msi "${VM_PATH}/unattended"
            web_get https://www.spice-space.org/download/windows/usbdk/UsbDk_1.0.22_x64.msi "${VM_PATH}/unattended"
            echo "Making unattended.iso"
            unattended_windows "${VM_PATH}/unattended/autounattend.xml"
            mkisofs -quiet -l -o "${VM_PATH}/unattended.iso" "${VM_PATH}/unattended/"
            ;;
    esac

    if [ -n "${FILE_NAME}" ]; then
        make_vm_config "${FILE_NAME}" "virtio-win.iso"
    else
        make_vm_config "windows-${RELEASE}.iso" "virtio-win.iso"
    fi
}

function open_homepage() {
    local URL=""
    local XDG_OPEN=""
    if [ -z "$(os_info "${1}")" ]; then
        error_specify_os
    else
        URL="$(os_info "${1}" | cut -d'|' -f 4)"
        # shellcheck disable=SC2034
        XDG_OPEN=$(xdg-open "${URL}" || sensible-browser "${URL}" || x-www-browser "${URL}" || gnome-open "${URL}")
        exit 0
    fi
}

function create_vm() {
    # shellcheck disable=SC2206
    local URL_HASH=(${1// / })
    local URL="${URL_HASH[0]}"
    local HASH="${URL_HASH[1]}"
    local ISO="${URL##*/}"
    #echo "${URL}"
    #echo "${ISO}"
    #echo "${HASH}"
    web_get "${URL}" "${VM_PATH}"
    if [ -n "${HASH}" ]; then
        check_hash "${ISO}" "${HASH}"
    fi

    case "${OS}" in
        batocera)
            if [[ ${ISO} = *".gz"* ]]; then
                gzip -d "${VM_PATH}/${ISO}"
                ISO="${ISO/.gz/}"
            fi;;
        dragonflybsd)
            #  Could be other OS iso files compressed with bzip2 or gzip
            #  but for now we'll keep this to know cases
            if [[ ${ISO} = *".bz2"* ]]; then
                bzip2 -d  "${VM_PATH}/${ISO}"
                ISO="${ISO/.bz2/}"
            fi;;
        easyos)
            if [[ ${ISO} = *".img"* ]]; then
                ${QEMU_IMG} convert -f raw -O qcow2 "${VM_PATH}/${ISO}" "${VM_PATH}/disk.qcow2"
                ISO="${ISO/.img/}"
            fi;;
        freedos)
            if [[ ${ISO} = *".zip"* ]]; then
                unzip -qo "${VM_PATH}/${ISO}" -d "${VM_PATH}"
                rm -f "${VM_PATH}/${ISO}"
                ISO="$(ls -1 "${VM_PATH}/"*.iso)"
            fi;;
        reactos)
            if [[ ${ISO} = *".zip"* ]]; then
                unzip -qo "${VM_PATH}/${ISO}" -d "${VM_PATH}"
                rm -f "${VM_PATH}/${ISO}"
                ISO="$(ls -1 "${VM_PATH}/"*.iso)"
            fi;;
    esac
    make_vm_config "${ISO}"
}

# Use command -v command to check if quickemu is in the system's PATH and
# fallback to checking if quickemu is in the current directory.
function resolve_quickemu() {
    if command -v quickemu >/dev/null 2>&1; then
        command -v quickemu
    elif [ -f "./quickemu" ]; then
        echo "$(pwd)/quickemu"
    else
        echo "quickemu not found" >&2
        exit 1
    fi
}

function help_message() {
    #shellcheck disable=SC2016
    printf '
             _      _              _
  __ _ _   _(_) ___| | ____ _  ___| |_
 / _` | | | | |/ __| |/ / _` |/ _ \ __|
| (_| | |_| | | (__|   < (_| |  __/ |_
 \__, |\__,_|_|\___|_|\_\__, |\___|\__|
    |_|                 |___/ v%s, using curl %s
--------------------------------------------------------------------------------
 Project - https://github.com/quickemu-project/quickemu
 Discord - https://wimpysworld.io/discord
--------------------------------------------------------------------------------

Usage:
  quickget <os> <release> [edition]
  quickget ubuntu 22.04

Advanced usage:
  quickget <arg> [path] <os> [release] [edition]
  quickget --download ubuntu 22.04

Arguments:
  --download      <os> <release> [edition] : Download image; no VM configuration
  --create-config <os> [path/url]          : Create VM config for a OS image
  --open-homepage <os>                     : Open homepage for the OS
  --show          [os]                     : Show OS information
  --version                                : Show version
  --help                                   : Show this help message
-------------------------- For testing & development ---------------------------
  --url           [os] [release] [edition] : Show image URL(s)
  --check         [os] [release] [edition] : Check image URL(s)
  --list                                   : List all supported systems
  --list-csv                               : List everything in csv format
  --list-json                              : List everything in json format
--------------------------------------------------------------------------------

Supported Operating Systems:\n\n' "$(${QUICKEMU} --version)" "${CURL_VERSION}"
    os_support | fmt -w 80
}

trap cleanup EXIT

if ((BASH_VERSINFO[0] < 4)); then
    echo "Sorry, you need bash 4.0 or newer to run this script."
    exit 1
fi

QUICKEMU=quickemu
I18NS=()
OPERATION=""
CURL=$(command -v curl)
if [ ! -x "${CURL}" ]; then
    echo "ERROR! curl not found. Please install curl"
    exit 1
fi
CURL_VERSION=$("${CURL}" --version | head -n 1 | cut -d' ' -f2)

QEMU_IMG=$(command -v qemu-img)
if [ ! -x "${QEMU_IMG}" ]; then
    echo "ERROR! qemu-img not found. Please make sure qemu-img is installed."
    exit 1
fi

#TODO: Deprecate `list`, `list_csv`, and `list_json` in favor of `--list`, `--list-csv`, and `--list-json`
case "${1}" in
    --download|-download)
        OPERATION="download"
        shift
        ;;
    --create-config|-create-config)
        OPERATION="config"
        shift
        create_config "${@}"
        ;;
    --open-homepage|-open-homepage)
        shift
        open_homepage "${1}"
        ;;
    --show|-show)
        shift
        if [ -z "${1}" ]; then
            for OS in $(os_support); do
                show_os_info "${OS}"
            done
        else
            show_os_info "${1}"
        fi
        exit 0;;
    --version|-version)
        WHERE=$(dirname "${BASH_SOURCE[0]}")
        "${WHERE}/quickemu" --version
        exit 0;;
    --help|-help|--h|-h)
        help_message
        exit 0;;
    --url|-url)
        OPERATION="show"
        shift
        if [ -z "${1}" ]; then
            for OS in $(os_support); do
                (test_all "${OS}")
            done
            exit 0
        elif [ -z "${2}" ]; then
            test_all "${1}"
            exit 0
        fi;;
    --check|-check)
        OPERATION="test"
        shift
        if [ -z "${1}" ]; then
            for OS in $(os_support); do
                (test_all "${OS}")
            done
            exit 0
        elif [ -z "${2}" ]; then
            test_all "${1}"
            exit 0
        fi;;
    --list-csv|-list-csv|list|list_csv) list_csv;;
    --list-json|-list-json|list_json) list_json;;
    --list|-list) list_supported;;
    -*) error_not_supported_argument;;
esac

if [ -n "${1}" ]; then
    OS="${1,,}"
else
    error_specify_os
fi

os_supported

if [ -n "${2}" ]; then
    RELEASE="${2}"
    VM_PATH="${OS}-${RELEASE}"
    # If the OS has an editions_() function, use it.
    if [[ $(type -t "editions_${OS}") == function ]]; then
        validate_release "releases_${OS}"
        EDITIONS=("$(editions_"${OS}")")
        if [ -n "${3}" ]; then
            EDITION="${3}"
            if [[ ! "${EDITIONS[*]}" = *"${EDITION}"* ]]; then
                echo -e "ERROR! ${EDITION} is not a supported $(pretty_name "${OS}") edition\n"
                echo -n ' - Supported editions: '
                for EDITION in "${EDITIONS[@]}"; do
                    echo -n "${EDITION} "
                done
                echo ""
                exit 1
            fi
        else
            show_os_info "${OS}"
            echo -e " - Editions:\t$("editions_${OS} | fmt -w 80")"
            echo -e "\nERROR! You must specify an edition."
            exit 1
        fi
        handle_missing
        VM_PATH="${OS}-${RELEASE}-${EDITION}"
        create_vm "$("get_${OS}" "${EDITION}")"
    elif [ "${OS}" == "macos" ]; then
        # macOS doesn't use create_vm()
        validate_release releases_macos
        get_macos
    elif [[ "${OS}" == *"ubuntu-server"* ]]; then
        # (Comes before regular Ubuntu, or the code tries to download the desktop) #
        # Ubuntu doesn't use create_vm()
        validate_release releases_ubuntu-server
        get_ubuntu-server
    elif [[ "${OS}" == *"ubuntu"* ]]; then
        # Ubuntu doesn't use create_vm()
        validate_release releases_ubuntu
        get_ubuntu
    elif [[ "${OS}" == "windows"* ]]; then
        I18N="English International"
        "languages_${OS}"
        if [ -n "${3}" ]; then
            I18N="${3}"
            if [[ ! "${I18NS[*]}" = *"${I18N}"* ]]; then
                error_not_supported_lang
            fi
            VM_PATH="$(echo "${OS}-${RELEASE}-${I18N// /-}" | tr -d '()')"
        fi
        validate_release "releases_${OS}"
        get_windows
    else
        validate_release "releases_${OS}"
        create_vm "$("get_${OS}")"
    fi
else
    error_specify_release
fi

# vim:tabstop=4:shiftwidth=4:expandtab

