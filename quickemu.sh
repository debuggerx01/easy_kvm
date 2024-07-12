#!/usr/bin/env bash
export LC_ALL=C

if ((BASH_VERSINFO[0] < 4)); then
    echo "Sorry, you need bash 4.0 or newer to run this script."
    exit 1
fi

function ignore_msrs_always() {
    # Make sure the host has /etc/modprobe.d
    if [ -d /etc/modprobe.d ]; then
        # Skip if ignore_msrs is already enabled, assumes initramfs has been rebuilt
        if grep -lq 'ignore_msrs=Y' /etc/modprobe.d/kvm-quickemu.conf >/dev/null 2>&1; then
            echo "options kvm ignore_msrs=Y" | sudo tee /etc/modprobe.d/kvm-quickemu.conf
            sudo update-initramfs -k all -u
        fi
    else
        echo "ERROR! /etc/modprobe.d was not found, I don't know how to configure this system."
        exit 1
    fi
}

function ignore_msrs_alert() {
    local ignore_msrs=""
    if [ "${OS_KERNEL}" == "Darwin" ]; then
        return
    elif [ -e /sys/module/kvm/parameters/ignore_msrs ]; then
        ignore_msrs=$(cat /sys/module/kvm/parameters/ignore_msrs)
        if [ "${ignore_msrs}" == "N" ]; then
            echo " - MSR:      WARNING! Ignoring unhandled Model-Specific Registers is disabled."
            echo
            echo "             echo 1 | sudo tee /sys/module/kvm/parameters/ignore_msrs"
            echo
            echo "             If you are unable to run macOS or Windows VMs then run the above 👆"
            echo "             This will enable ignoring of unhandled MSRs until you reboot the host."
            echo "             You can make this change permanent by running: 'quickemu --ignore-msrs-always'"
        fi
    fi
}

function delete_shortcut() {
    local SHORTCUT_DIR="${HOME}/.local/share/applications"
    if [ -e "${SHORTCUT_DIR}/${VMNAME}.desktop" ]; then
        rm "${SHORTCUT_DIR}/${VMNAME}.desktop"
        echo " - Deleted ${SHORTCUT_DIR}/${VMNAME}.desktop"
    fi
}

function delete_disk() {
    echo "Deleting ${VMNAME} virtual hard disk"
    if [ -e "${disk_img}" ]; then
        rm "${disk_img}" >/dev/null 2>&1
        # Remove any EFI vars, but not for macOS
        rm "${VMDIR}"/OVMF_VARS*.fd >/dev/null 2>&1
        rm "${VMDIR}/${VMNAME}-vars.fd" >/dev/null 2>&1
        echo " - Deleted ${disk_img}"
        delete_shortcut
    else
        echo " - ${disk_img} not found. Doing nothing."
    fi
}

function delete_vm() {
    echo "Deleting ${VMNAME} completely"
    if [ -d "${VMDIR}" ]; then
        rm -rf "${VMDIR}"
        rm "${VM}"
        echo " - Deleted ${VM} and ${VMDIR}/"
        delete_shortcut
    else
        echo " - ${VMDIR} not found. Doing nothing."
    fi
}

function kill_vm() {
    echo "Killing ${VMNAME}"
    if [ -z "${VM_PID}" ]; then
        echo " - ${VMNAME} is not running."
        rm -f "${VMDIR}/${VMNAME}.pid"
    elif [ -n "${VM_PID}" ]; then
        if kill -9 "${VM_PID}" > /dev/null 2>&1; then
            echo " - ${VMNAME} (${VM_PID}) killed."
            rm -f "${VMDIR}/${VMNAME}.pid"
        else
            echo " - ${VMNAME} (${VM_PID}) was not killed."
        fi
    elif [ ! -r "${VMDIR}/${VMNAME}.pid" ]; then
        echo " - ${VMNAME} has no ${VMDIR}/${VMNAME}.pid"
    fi
}

function snapshot_apply() {
    echo "Snapshot apply to ${disk_img}"
    local TAG="${1}"
    if [ -z "${TAG}" ]; then
        echo " - ERROR! No snapshot tag provided."
        exit
    fi

    if [ -e "${disk_img}" ]; then
        if ${QEMU_IMG} snapshot -q -a "${TAG}" "${disk_img}"; then
            echo " - Applied snapshot '${TAG}' to ${disk_img}"
        else
            echo " - ERROR! Failed to apply snapshot '${TAG}' to ${disk_img}"
        fi
    else
        echo " - NOTE! ${disk_img} not found. Doing nothing."
    fi
}

function snapshot_create() {
    echo "Snapshotting ${disk_img}"
    local TAG="${1}"
    if [ -z "${TAG}" ]; then
        echo "- ERROR! No snapshot tag provided."
        exit
    fi

    if [ -e "${disk_img}" ]; then
        if ${QEMU_IMG} snapshot -q -c "${TAG}" "${disk_img}"; then
            echo " - Created snapshot '${TAG}' for ${disk_img}"
        else
            echo " - ERROR! Failed to create snapshot '${TAG}' for ${disk_img}"
        fi
    else
        echo " - NOTE! ${disk_img} not found. Doing nothing."
    fi
}

function snapshot_delete() {
    echo "Snapshot removal ${disk_img}"
    local TAG="${1}"
    if [ -z "${TAG}" ]; then
        echo " - ERROR! No snapshot tag provided."
        exit
    fi

    if [ -e "${disk_img}" ]; then
        if ${QEMU_IMG} snapshot -q -d "${TAG}" "${disk_img}"; then
            echo " - Deleted snapshot '${TAG}' from ${disk_img}"
        else
            echo " - ERROR! Failed to delete snapshot '${TAG}' from ${disk_img}"
        fi
    else
        echo " - NOTE! ${disk_img} not found. Doing nothing."
    fi
}

function snapshot_info() {
    echo
    if [ -e "${disk_img}" ]; then
        ${QEMU_IMG} info "${disk_img}"
    fi
}

function get_port() {
    local PORT_START=$1
    local PORT_RANGE=$((PORT_START+$2))
    local PORT
    for ((PORT = PORT_START; PORT <= PORT_RANGE; PORT++)); do
        # Make sure port scans do not block too long.
        timeout 0.1s bash -c "echo >/dev/tcp/127.0.0.1/${PORT}" >/dev/null 2>&1
        if [ ${?} -eq 1 ]; then
            echo "${PORT}"
            break
        fi
    done
}

function configure_usb() {
    local DEVICE=""
    local USB_BUS=""
    local USB_DEV=""
    local USB_NAME=""
    local VENDOR_ID=""
    local PRODUCT_ID=""
    local USB_NOT_READY=0

    # Have any USB devices been requested for pass-through?
    if (( ${#usb_devices[@]} )); then
        echo " - USB:      Host pass-through requested:"
        for DEVICE in "${usb_devices[@]}"; do
            VENDOR_ID=$(echo "${DEVICE}" | cut -d':' -f1)
            PRODUCT_ID=$(echo "${DEVICE}" | cut -d':' -f2)
            USB_BUS=$(lsusb -d "${VENDOR_ID}:${PRODUCT_ID}" | cut -d' ' -f2)
            USB_DEV=$(lsusb -d "${VENDOR_ID}:${PRODUCT_ID}" | cut -d' ' -f4 | cut -d':' -f1)
            USB_NAME=$(lsusb -d "${VENDOR_ID}:${PRODUCT_ID}" | cut -d' ' -f7-)
            if [ -z "${USB_NAME}" ]; then
                echo "             ! USB device ${VENDOR_ID}:${PRODUCT_ID} not found. Check your configuration"
                continue
            elif [ -w "/dev/bus/usb/${USB_BUS}/${USB_DEV}" ]; then
                echo "             o ${USB_NAME} on bus ${USB_BUS} device ${USB_DEV} is accessible."
            else
                echo "             x ${USB_NAME} on bus ${USB_BUS} device ${USB_DEV} needs permission changes:"
                echo "               sudo chown -v root:${USER} /dev/bus/usb/${USB_BUS}/${USB_DEV}"
                USB_NOT_READY=1
            fi
            USB_PASSTHROUGH="${USB_PASSTHROUGH} -device usb-host,bus=hostpass.0,vendorid=0x${VENDOR_ID},productid=0x${PRODUCT_ID}"
        done

        if [ "${USB_NOT_READY}" -eq 1 ]; then
            echo "               ERROR! USB permission changes are required 👆"
            exit 1
        fi
    fi
}

# get the number of processing units
function get_nproc() {
    if command -v nproc &>/dev/null; then
        nproc
    elif command -v sysctl &>/dev/null; then
        sysctl -n hw.ncpu
    else
        echo "ERROR! Unable to determine the number of processing units."
        exit 1
    fi
}

# macOS and Linux compatible get_cpu_info function
function get_cpu_info() {
    local INFO_NAME="${1}"

    if [ "${OS_KERNEL}" == "Darwin" ]; then
        if [ "^Model name:" == "${INFO_NAME}" ]; then
            sysctl -n machdep.cpu.brand_string
        elif [ "Socket" == "${INFO_NAME}" ]; then
            sysctl -n hw.packages
        elif [ "Vendor" == "${INFO_NAME}" ]; then
            if [ "${ARCH_HOST}" == "arm64" ]; then
                sysctl -n machdep.cpu.brand_string | cut -d' ' -f1
            else
                sysctl -n machdep.cpu.vendor | sed 's/ //g'
            fi
        else
            echo "ERROR! Could not find macOS translation for ${INFO_NAME}"
            exit 1
        fi
    else
        if [ "^Model name:" == "${INFO_NAME}" ]; then
            for MODEL_NAME in $(IFS=$'\n' lscpu | grep "${INFO_NAME}" | cut -d':' -f2 | sed -e 's/^[[:space:]]*//'); do
                echo -n "${MODEL_NAME} "
            done
        else
            lscpu | grep -E "${INFO_NAME}" | cut -d':' -f2 | sed 's/ //g' | sort -u
        fi
    fi
}

# returns an enabled or disable CPU flag for QEMU, based on the host CPU
# capabilities, or nothing if the flag is not supported
# converts the flags appropriately from macOS and Linux to QEMU
function configure_cpu_flag() {
    local HOST_CPU_FLAG="${1}"
    # Convert the flag to lowercase for QEMU
    local QEMU_CPU_FLAG=${HOST_CPU_FLAG,,}
    if check_cpu_flag "${HOST_CPU_FLAG}"; then
        # Replace _ with - to make it compatible with QEMU
        QEMU_CPU_FLAG="${HOST_CPU_FLAG//_/-}"
        QEMU_CPU_FLAG="${QEMU_CPU_FLAG//4_/4\.}"
        # macOS uses different flag names
        if [ "${OS_KERNEL}" == "Darwin" ]; then
            case "${HOST_CPU_FLAG}" in
                avx) QEMU_CPU_FLAG="AVX1.0";;
            esac
        fi
        echo ",+${QEMU_CPU_FLAG}"
    else
        # Fully disable any QEMU flags that are not supported by the host CPU
        if [ "${HOST_CPU_VENDOR}" == "AuthenticAMD" ]; then
            case ${HOST_CPU_FLAG} in
                pcid) echo ",-${QEMU_CPU_FLAG}";;
            esac
        fi
    fi
}

# checks if a CPU flag is supported by the host CPU on Linux and macOS
function check_cpu_flag() {
    local HOST_CPU_FLAG=""
    if [ "${OS_KERNEL}" == "Darwin" ]; then
        # Make the macOS compatible: uppercase, replace _ with . and replace X2APIC with x2APIC
        HOST_CPU_FLAG="${1^^}"
        HOST_CPU_FLAG="${HOST_CPU_FLAG//_/.}"
        HOST_CPU_FLAG="${HOST_CPU_FLAG//X2APIC/x2APIC}"
        if [ "${HOST_CPU_FLAG}" == "AVX" ]; then
            HOST_CPU_FLAG="AVX1.0"
        fi
        if sysctl -n machdep.cpu.features | grep -o "${HOST_CPU_FLAG}" > /dev/null; then
            return 0
        else
            return 1
        fi
    else
      HOST_CPU_FLAG="${1}"
      if lscpu | grep -o "^Flags\b.*: .*\b${HOST_CPU_FLAG}\b" > /dev/null; then
          return 0
      else
          return 1
      fi
    fi
}

function efi_vars() {
    local VARS_IN=""
    local VARS_OUT=""
    VARS_IN="${1}"
    VARS_OUT="${2}"

    if [ ! -e "${VARS_OUT}" ]; then
        if [ -e "${VARS_IN}" ]; then
            cp "${VARS_IN}" "${VARS_OUT}"
        else
            echo "ERROR! ${VARS_IN} was not found. Please install edk2."
            exit 1
        fi
    fi
}

function configure_cpu() {
    HOST_CPU_CORES=$(get_nproc)
    HOST_CPU_MODEL=$(get_cpu_info '^Model name:')
    HOST_CPU_SOCKETS=$(get_cpu_info 'Socket')
    HOST_CPU_VENDOR=$(get_cpu_info 'Vendor')

    CPU_MODEL="host"
    QEMU_ACCEL="tcg"
    # Configure appropriately for the host platform
    if [ "${OS_KERNEL}" == "Darwin" ]; then
        MANUFACTURER=$(ioreg -l | grep -e Manufacturer | grep -v iMan | cut -d'"' -f4 | sort -u)
        CPU_KVM_UNHALT=""
        QEMU_ACCEL="hvf"
        # QEMU for macOS from Homebrew does not support SMM
        SMM="off"
    else
        if [ -r /sys/class/dmi/id/sys_vendor ]; then
            MANUFACTURER=$(head -n 1 /sys/class/dmi/id/sys_vendor)
        fi
        CPU_KVM_UNHALT=",kvm_pv_unhalt"
        GUEST_TWEAKS+=" -global kvm-pit.lost_tick_policy=discard"
        QEMU_ACCEL="kvm"
    fi

    if [ "${ARCH_VM}" == "aarch64"  ]; then
        # Support to run aarch64 VMs (best guess; untested)
        # https://qemu-project.gitlab.io/qemu/system/arm/virt.html
        case ${ARCH_HOST} in
            arm64|aarch64) CPU_MODEL="max"
                           MACHINE_TYPE="virt,highmem=off";;
        esac
    elif [ "${ARCH_VM}" != "${ARCH_HOST}" ]; then
        # If the architecture of the VM is different from the host, disable acceleration
        CPU_MODEL="qemu64"
        CPU_KVM_UNHALT=""
        QEMU_ACCEL="tcg"
    fi

    # TODO: More robust detection of running in a VM
    # - macOS check for CPU flag: vmx
    # - Linux AMD check for CPU flag: svm
    # - Linux Intel check for CPU flag: vmx
    case ${MANUFACTURER,,} in
        qemu|virtualbox) CPU_MODEL="qemu64"
                         QEMU_ACCEL="tcg"
                         HYPERVISOR="${MANUFACTURER,,}";;
        *) HYPERVISOR="";;
    esac

    if [ -z "${HYPERVISOR}" ]; then
        # A CPU with Intel VT-x / AMD SVM support is required
        if [ "${HOST_CPU_VENDOR}" == "GenuineIntel" ]; then
            if ! check_cpu_flag vmx; then
                echo "ERROR! Intel VT-x support is required."
                exit 1
            fi
        elif [ "${HOST_CPU_VENDOR}" == "AuthenticAMD" ]; then
            if ! check_cpu_flag svm; then
                echo "ERROR! AMD SVM support is required."
                exit 1
            fi
        fi
    fi

    CPU="-cpu ${CPU_MODEL}"

    # Make any OS specific adjustments
    if [ "${guest_os}" == "freedos" ] || [ "${guest_os}" == "windows" ] || [ "${guest_os}" == "windows-server" ]; then
        # SMM is not available on QEMU for macOS via Homebrew
        if [ "${OS_KERNEL}" == "Linux" ]; then
            SMM="on"
        fi
    fi

    case ${guest_os} in
        batocera|freedos|haiku|solaris) MACHINE_TYPE="pc";;
        kolibrios|reactos)
            CPU="-cpu qemu32"
            MACHINE_TYPE="pc";;
        macos)
            # If the host has an Intel CPU, passes the host CPU model features, model, stepping, exactly to the guest.
            # Disable huge pages (,-pdpe1gb) on macOS to prevent crashes
            # - https://stackoverflow.com/questions/60231203/qemu-qcow2-mmu-gva-to-gpa-crash-in-mac-os-x
            if [ "${HOST_CPU_VENDOR}" == "GenuineIntel" ] && [ -z "${HYPERVISOR}" ]; then
                CPU_MODEL="host"
                CPU="-cpu ${CPU_MODEL},-pdpe1gb,+hypervisor"
            else
                CPU_MODEL="Haswell-v2"
                CPU="-cpu ${CPU_MODEL},vendor=GenuineIntel,-pdpe1gb,+avx,+sse,+sse2,+ssse3,vmware-cpuid-freq=on"
            fi
            # A CPU with fma is required for Metal support
            # A CPU with invtsc is required for macOS to boot
            case ${macos_release} in
                ventura|sonoma)
                    # A CPU with AVX2 support is required for >= macOS Ventura
                    if check_cpu_flag sse4_2 && check_cpu_flag avx2; then
                        if [ "${HOST_CPU_VENDOR}" != "GenuineIntel" ] && [ -z "${HYPERVISOR}" ]; then
                            CPU+=",+avx2,+sse4.2"
                        fi
                    else
                        echo "ERROR! macOS ${macos_release} requires a CPU with SSE 4.2 and AVX2 support."
                        echo "       Try macOS Monterey or Big Sur."
                        exit 1
                    fi;;
                catalina|big-sur|monterey)
                    # A CPU with SSE4.2 support is required for >= macOS Catalina
                    if check_cpu_flag sse4_2; then
                        if [ "${HOST_CPU_VENDOR}" != "GenuineIntel" ] && [ -z "${HYPERVISOR}" ]; then
                            CPU+=",+sse4.2"
                        fi
                    else
                        echo "ERROR! macOS ${macos_release} requires a CPU with SSE 4.2 support."
                        exit 1
                    fi;;
                *)
                    # A CPU with SSE4.1 support is required for >= macOS Sierra
                    if check_cpu_flag sse4_1; then
                        if [ "${HOST_CPU_VENDOR}" != "GenuineIntel" ] && [ -z "${HYPERVISOR}" ]; then
                            CPU+=",+sse4.1"
                        fi
                    else
                        echo "ERROR! macOS ${macos_release} requires a CPU with SSE 4.1 support."
                        exit 1
                    fi;;
            esac

            if [ "${HOST_CPU_VENDOR}" != "GenuineIntel" ] && [ -z "${HYPERVISOR}" ]; then
                for FLAG in abm adx aes amd-ssbd apic arat bmi1 bmi2 clflush cmov cx8 cx16 de \
                            eist erms f16c fma fp87 fsgsbase fxsr invpcid invtsc lahf_lm lm \
                            mca mce mmx movbe mpx msr mtrr nx pae pat pcid pge pse popcnt pse36 \
                            rdrand rdtscp sep smep syscall tsc tsc_adjust vaes vbmi2 vmx vpclmulqdq \
                            x2apic xgetbv1 xsave xsaveopt; do
                    CPU+=$(configure_cpu_flag "${FLAG}")
                done
            fi

            # Disable S3 support in the VM to prevent macOS suspending during install
            GUEST_TWEAKS+=" -global ICH9-LPC.disable_s3=1 -device isa-applesmc,osk=$(echo "bheuneqjbexolgurfrjbeqfthneqrqcyrnfrqbagfgrny(p)NccyrPbzchgreVap" | tr 'A-Za-z' 'N-ZA-Mn-za-m')"

            # Disable High Precision Timer
            if [ "${QEMU_VER_SHORT}" -ge 70 ]; then
                MACHINE_TYPE+=",hpet=off"
            else
                GUEST_TWEAKS+=" -no-hpet"
            fi
            ;;
        windows|windows-server)
            if [ "${QEMU_VER_SHORT}" -gt 60 ]; then
                CPU="-cpu ${CPU_MODEL},+hypervisor,+invtsc,l3-cache=on,migratable=no,hv_passthrough"
            else
                CPU="-cpu ${CPU_MODEL},+hypervisor,+invtsc,l3-cache=on,migratable=no,hv_frequencies${CPU_KVM_UNHALT},hv_reenlightenment,hv_relaxed,hv_spinlocks=8191,hv_stimer,hv_synic,hv_time,hv_vapic,hv_vendor_id=1234567890ab,hv_vpindex"
            fi
            # Disable S3 support in the VM to ensure Windows can boot with SecureBoot enabled
            #  - https://wiki.archlinux.org/title/QEMU#VM_does_not_boot_when_using_a_Secure_Boot_enabled_OVMF
            GUEST_TWEAKS+=" -global ICH9-LPC.disable_s3=1"

            # Disable High Precision Timer
            if [ "${QEMU_VER_SHORT}" -ge 70 ]; then
              MACHINE_TYPE+=",hpet=off"
            else
              GUEST_TWEAKS+=" -no-hpet"
            fi
            ;;
    esac

    if [ "${HOST_CPU_VENDOR}" == "AuthenticAMD" ] && [ "${guest_os}" != "macos" ]; then
        CPU+=",topoext"
    fi

    if [ -z "${cpu_cores}" ]; then
        if [ "${HOST_CPU_CORES}" -ge 32 ]; then
            GUEST_CPU_CORES="16"
        elif [ "${HOST_CPU_CORES}" -ge 16 ]; then
            GUEST_CPU_CORES="8"
        elif [ "${HOST_CPU_CORES}" -ge 8 ]; then
            GUEST_CPU_CORES="4"
        elif [ "${HOST_CPU_CORES}" -ge 4 ]; then
            GUEST_CPU_CORES="2"
        else
            GUEST_CPU_CORES="1"
        fi
    else
        GUEST_CPU_CORES="${cpu_cores}"
    fi

    # macOS guests cannot boot with most core counts not powers of 2.
    # Find the nearest but lowest power of 2 using a predefined table
    if [ "${guest_os}" == "macos" ]; then
        local POWERS=(1 2 4 8 16 32 64 128 256 512 1024)
        for (( i=${#POWERS[@]}-1; i>=0; i-- )); do
            if [ "${POWERS[i]}" -le "${GUEST_CPU_CORES}" ]; then
                GUEST_CPU_CORES="${POWERS[i]}"
                break
            fi
        done
    fi

    if [ "${OS_KERNEL}" == "Darwin" ]; then
        # Get the number of physical cores
        physicalcpu=$(sysctl -n hw.physicalcpu)
        # Get the number of logical processors
        logicalcpu=$(sysctl -n hw.logicalcpu)
        # Check if Hyper-Threading is enabled
        if [ "${logicalcpu}" -gt "${physicalcpu}" ]; then
            HOST_CPU_SMT="on"
        else
            HOST_CPU_SMT="off"
        fi
    elif [ -e /sys/devices/system/cpu/smt/control ]; then
        HOST_CPU_SMT=$(cat /sys/devices/system/cpu/smt/control)
    fi

    # Account for Hyperthreading/SMT.
    if [ "${GUEST_CPU_CORES}" -ge 2 ]; then
        case ${HOST_CPU_SMT} in
            on) GUEST_CPU_THREADS=2
                GUEST_CPU_LOGICAL_CORES=$(( GUEST_CPU_CORES / GUEST_CPU_THREADS ));;
            *)  GUEST_CPU_THREADS=1
                GUEST_CPU_LOGICAL_CORES=${GUEST_CPU_CORES};;
        esac
    else
        GUEST_CPU_THREADS=1
        GUEST_CPU_LOGICAL_CORES=${GUEST_CPU_CORES}
    fi

    SMP="-smp cores=${GUEST_CPU_LOGICAL_CORES},threads=${GUEST_CPU_THREADS},sockets=${HOST_CPU_SOCKETS}"
    echo " - CPU:      ${HOST_CPU_MODEL}"
    echo " - CPU VM:   ${CPU_MODEL%%,*}, ${HOST_CPU_SOCKETS} Socket(s), ${GUEST_CPU_LOGICAL_CORES} Core(s), ${GUEST_CPU_THREADS} Thread(s)"

    if [ "${guest_os}" == "macos" ] || [ "${guest_os}" == "windows" ] || [ "${guest_os}" == "windows-server" ]; then
        # Display MSRs alert if the guest is macOS or windows
        ignore_msrs_alert
    fi
}

function configure_ram() {
    local OS_PRETTY_NAME=""
    RAM_VM="2G"
    if [ -z "${ram}" ]; then
        local RAM_HOST=""
        if [ "${OS_KERNEL}" == "Darwin" ]; then
            RAM_HOST=$(($(sysctl -n hw.memsize) / (1048576*1024)))
        else
            # Determine the number of gigabytes of RAM in the host by extracting the first numerical value from the output.
            RAM_HOST=$(free --giga | tr ' ' '\n' | grep -m 1 "[0-9]" )
        fi

        if [ "${RAM_HOST}" -ge 128 ]; then
            RAM_VM="32G"
        elif [ "${RAM_HOST}" -ge 64 ]; then
            RAM_VM="16G"
        elif [ "${RAM_HOST}" -ge 16 ]; then
            RAM_VM="8G"
        elif [ "${RAM_HOST}" -ge 8 ]; then
            RAM_VM="4G"
        fi
    else
        RAM_VM="${ram}"
    fi
    echo " - RAM VM:   ${RAM_VM} RAM"

    case "${guest_os}" in
        windows|windows-server)
            OS_PRETTY_NAME="Windows"
            min_ram="4"
            ;;
        macos)
            OS_PRETTY_NAME="macOS"
            min_ram="8"
            ;;
    esac

    if [ -n "${min_ram}" ] && [ "${RAM_VM//G/}" -lt "${min_ram}" ]; then
        if [ -z "${ram}" ]; then
            echo "             ERROR! The guest virtual machine has been allocated insufficient RAM to run ${OS_PRETTY_NAME}."
            echo "             You can override the guest RAM allocation by adding 'ram=${min_ram}G' to ${VM}"
            exit 1
        else
            echo "             WARNING! You have allocated less than the recommended amount of RAM to run ${OS_PRETTY_NAME}."
        fi
    fi
}

function configure_bios() {
    # Always Boot macOS using EFI
    if [ "${guest_os}" == "macos" ]; then
        boot="efi"
        if [ -e "${VMDIR}/OVMF_CODE.fd" ] && [ -e "${VMDIR}/OVMF_VARS-1024x768.fd" ]; then
            EFI_CODE="${VMDIR}/OVMF_CODE.fd"
            EFI_VARS="${VMDIR}/OVMF_VARS-1024x768.fd"
        elif [ -e "${VMDIR}/OVMF_CODE.fd" ] && [ -e "${VMDIR}/OVMF_VARS-1920x1080.fd" ]; then
            EFI_CODE="${VMDIR}/OVMF_CODE.fd"
            EFI_VARS="${VMDIR}/OVMF_VARS-1920x1080.fd"
        else
            MAC_MISSING="Firmware"
        fi

        if [ -e "${VMDIR}/OpenCore.qcow2" ]; then
            MAC_BOOTLOADER="${VMDIR}/OpenCore.qcow2"
        elif [ -e "${VMDIR}/ESP.qcow2" ]; then
            # Backwards compatibility for Clover
            MAC_BOOTLOADER="${VMDIR}/ESP.qcow2"
        else
            MAC_MISSING="Bootloader"
        fi

        if [ -n "${MAC_MISSING}" ]; then
            echo "ERROR! macOS ${MAC_MISSING} was not found."
            echo "       Use 'quickget' to download the required files."
            exit 1
        fi
        BOOT_STATUS="EFI (macOS), OVMF ($(basename "${EFI_CODE}")), SecureBoot (${secureboot})."
    elif [[ "${boot}" == *"efi"* ]]; then
        EFI_VARS="${VMDIR}/OVMF_VARS.fd"

        # Preserve backward compatibility
        if [ -e "${VMDIR}/${VMNAME}-vars.fd" ]; then
            mv "${VMDIR}/${VMNAME}-vars.fd" "${EFI_VARS}"
        elif [ -e "${VMDIR}/OVMF_VARS_4M.fd" ]; then
            mv "${VMDIR}/OVMF_VARS_4M.fd" "${EFI_VARS}"
        fi

        # OVMF_CODE_4M.fd is for booting guests in non-Secure Boot mode.
        # While this image technically supports Secure Boot, it does so
        # without requiring SMM support from QEMU

        # OVMF_CODE.secboot.fd is like OVMF_CODE_4M.fd, but will abort if QEMU
        # does not support SMM.

        local SHARE_PATH="/usr/share"
        if [ "${OS_KERNEL}" == "Darwin" ]; then
            # Do not assume brew; quickemu could have been installed via Nix
            if command -v brew &>/dev/null; then
                SHARE_PATH="$(brew --prefix qemu)/share"
            fi
        fi

        # https://bugzilla.redhat.com/show_bug.cgi?id=1929357#c5
        # TODO: Check if macOS should use 'edk2-i386-vars.fd'
        if [ -n "${EFI_CODE}" ] || [ ! -e "${EFI_CODE}" ]; then
            case ${secureboot} in
                on) # shellcheck disable=SC2054,SC2140
                    ovmfs=("${SHARE_PATH}/OVMF/OVMF_CODE_4M.secboot.fd","${SHARE_PATH}/OVMF/OVMF_VARS_4M.fd" \
                        "${SHARE_PATH}/edk2/ovmf/OVMF_CODE.secboot.fd","${SHARE_PATH}/edk2/ovmf/OVMF_VARS.fd" \
                        "${SHARE_PATH}/OVMF/x64/OVMF_CODE.secboot.fd","${SHARE_PATH}/OVMF/x64/OVMF_VARS.fd" \
                        "${SHARE_PATH}/edk2-ovmf/OVMF_CODE.secboot.fd","${SHARE_PATH}/edk2-ovmf/OVMF_VARS.fd" \
                        "${SHARE_PATH}/qemu/ovmf-x86_64-smm-ms-code.bin","${SHARE_PATH}/qemu/ovmf-x86_64-smm-ms-vars.bin" \
                        "${SHARE_PATH}/qemu/edk2-x86_64-secure-code.fd","${SHARE_PATH}/qemu/edk2-x86_64-code.fd" \
                        "${SHARE_PATH}/edk2-ovmf/x64/OVMF_CODE.secboot.fd","${SHARE_PATH}/edk2-ovmf/x64/OVMF_VARS.fd"
                    );;
                *)  # shellcheck disable=SC2054,SC2140
                    ovmfs=("${SHARE_PATH}/OVMF/OVMF_CODE_4M.fd","${SHARE_PATH}/OVMF/OVMF_VARS_4M.fd" \
                        "${SHARE_PATH}/edk2/ovmf/OVMF_CODE.fd","${SHARE_PATH}/edk2/ovmf/OVMF_VARS.fd" \
                        "${SHARE_PATH}/OVMF/OVMF_CODE.fd","${SHARE_PATH}/OVMF/OVMF_VARS.fd" \
                        "${SHARE_PATH}/OVMF/x64/OVMF_CODE.fd","${SHARE_PATH}/OVMF/x64/OVMF_VARS.fd" \
                        "${SHARE_PATH}/edk2-ovmf/OVMF_CODE.fd","${SHARE_PATH}/edk2-ovmf/OVMF_VARS.fd" \
                        "${SHARE_PATH}/qemu/ovmf-x86_64-4m-code.bin","${SHARE_PATH}/qemu/ovmf-x86_64-4m-vars.bin" \
                        "${SHARE_PATH}/qemu/edk2-x86_64-code.fd","${SHARE_PATH}/qemu/edk2-x86_64-code.fd" \
                        "${SHARE_PATH}/edk2-ovmf/x64/OVMF_CODE.fd","${SHARE_PATH}/edk2-ovmf/x64/OVMF_VARS.fd"
                    );;
            esac
            # Attempt each EFI_CODE file one by one, selecting the corresponding code and vars
            # when an existing file is found.
            _IFS=$IFS
            IFS=","
            for f in "${ovmfs[@]}"; do
                # shellcheck disable=SC2086
                set -- ${f};
                if [ -e "${1}" ]; then
                    EFI_CODE="${1}"
                    EFI_EXTRA_VARS="${2}"
                fi
            done
            IFS=$_IFS
        fi
        if [ -z "${EFI_CODE}" ] || [ ! -e "${EFI_CODE}" ]; then
            if [ "${secureboot}" == "on" ]; then
                echo "ERROR! SecureBoot was requested but no SecureBoot capable firmware was found."
            else
                echo "ERROR! EFI boot requested but no EFI firmware found."
            fi
            echo "       Please install OVMF firmware."
            exit 1
        fi
        if [ -n "${EFI_EXTRA_VARS}" ]; then
            if [ ! -e "${EFI_EXTRA_VARS}" ]; then
                echo " - EFI:      ERROR! EFI_EXTRA_VARS file ${EFI_EXTRA_VARS} does not exist."
                exit 1
            fi
            efi_vars "${EFI_EXTRA_VARS}" "${EFI_VARS}"
        fi

        # Make sure EFI_VARS references an actual, writeable, file
        if [ ! -f "${EFI_VARS}" ] || [ ! -w "${EFI_VARS}" ]; then
            echo " - EFI:      ERROR! ${EFI_VARS} is not a regular file or not writeable."
            echo "             Deleting ${EFI_VARS}. Please re-run quickemu."
            rm -f "${EFI_VARS}"
            exit 1
        fi

        # If EFI_CODE references a symlink, resolve it to the real file.
        if [ -L "${EFI_CODE}" ]; then
            echo " - EFI:      WARNING! ${EFI_CODE} is a symlink."
            echo -n "             Resolving to... "
            EFI_CODE=$(realpath "${EFI_CODE}")
            echo "${EFI_CODE}"
        fi
        BOOT_STATUS="EFI (${guest_os^}), OVMF (${EFI_CODE}), SecureBoot (${secureboot})."
    else
        BOOT_STATUS="Legacy BIOS (${guest_os^})"
        boot="legacy"
        secureboot="off"
    fi

    echo " - BOOT:     ${BOOT_STATUS}"
}

function configure_os_quirks() {

    if [ "${guest_os}" == "batocera" ] || [ "${guest_os}" == "freedos" ] || [ "${guest_os}" == "haiku" ] || [ "${guest_os}" == "kolibrios" ]; then
        NET_DEVICE="rtl8139"
    fi

    if [ "${guest_os}" == "freebsd" ] || [ "${guest_os}" == "ghostbsd" ]; then
        mouse="usb"
    fi

    case ${guest_os} in
        windows-server) NET_DEVICE="e1000";;
        *bsd|linux*|windows) NET_DEVICE="virtio-net";;
        freedos) sound_card="sb16";;
        *solaris) usb_controller="xhci"
                  sound_card="ac97";;
        reactos) NET_DEVICE="e1000"
                 keyboard="ps2";;
        macos)
            # Tune QEMU optimisations based on the macOS release, or fallback to lowest
            # common supported options if none is specified.
            #   * VirtIO Block Media doesn't work in High Sierra (at all) or the Mojave (Recovery Image)
            #   * VirtIO Network is supported since Big Sur
            #   * VirtIO Memory Balloning is supported since Big Sur (https://pmhahn.github.io/virtio-balloon/)
            #   * VirtIO RNG is supported since Big Sur, but exposed to all guests by default.
            case ${macos_release} in
                big-sur|monterey|ventura|sonoma)
                    BALLOON="-device virtio-balloon"
                    MAC_DISK_DEV="virtio-blk-pci"
                    NET_DEVICE="virtio-net"
                    USB_HOST_PASSTHROUGH_CONTROLLER="nec-usb-xhci"
                    GUEST_TWEAKS+=" -global nec-usb-xhci.msi=off"
                    sound_card="${sound_card:-usb-audio}"
                    usb_controller="xhci";;
                *)
                    # Backwards compatibility if no macos_release is specified.
                    # Also safe catch all for High Sierra and Mojave
                    BALLOON=""
                    if [ "${macos_release}" == "catalina" ]; then
                        MAC_DISK_DEV="virtio-blk-pci"
                    else
                        MAC_DISK_DEV="ide-hd,bus=ahci.2"
                    fi
                    NET_DEVICE="vmxnet3"
                    USB_HOST_PASSTHROUGH_CONTROLLER="usb-ehci";;
            esac
            ;;
        *) NET_DEVICE="rtl8139";;
    esac
}

function configure_storage() {
    local create_options=""
    echo " - Disk:     ${disk_img} (${disk_size})"
    if [ ! -f "${disk_img}" ]; then
        # If there is no disk image, create a new image.
        mkdir -p "${VMDIR}" 2>/dev/null
        case ${preallocation} in
            off|metadata|falloc|full) true;;
            *) echo "ERROR! ${preallocation} is an unsupported disk preallocation option."
               exit 1;;
        esac

        case ${disk_format} in
            qcow2) create_options="lazy_refcounts=on,preallocation=${preallocation},nocow=on";;
            raw) create_options="preallocation=${preallocation}";;
            *) true;;
        esac

        # https://blog.programster.org/qcow2-performance
        if ! ${QEMU_IMG} create -q -f "${disk_format}" -o "${create_options=}" "${disk_img}" "${disk_size}"; then
            echo "ERROR! Failed to create ${disk_img} using ${disk_format} format."
            exit 1
        fi

        if [ -z "${iso}" ] && [ -z "${img}" ]; then
            echo "ERROR! You haven't specified a .iso or .img image to boot from."
            exit 1
        fi
        echo "             Just created, booting from ${iso}${img}"
        DISK_USED="no"
    elif [ -e "${disk_img}" ]; then
        # If the VM is not running, check for disk related issues.
        if [ -z "${VM_PID}" ]; then
            # Check there isn't already a process attached to the disk image.
            if ! ${QEMU_IMG} info "${disk_img}" >/dev/null; then
                echo "             Failed to get \"write\" lock. Is another process using the disk?"
                exit 1
            fi
        else
            if ! ${QEMU_IMG} check -q "${disk_img}"; then
                echo "             Disk integrity check failed. Please run qemu-img check --help."
                echo
                "${QEMU_IMG}" check "${disk_img}"
                exit 1
            fi
        fi

        # Only check disk image size if preallocation is off
        if [ "${preallocation}" == "off" ]; then
            DISK_CURR_SIZE=$(${STAT} -c%s "${disk_img}")
            if [ "${DISK_CURR_SIZE}" -le "${DISK_MIN_SIZE}" ]; then
                echo "             Looks unused, booting from ${iso}${img}"
                if [ -z "${iso}" ] && [ -z "${img}" ]; then
                    echo "ERROR! You haven't specified a .iso or .img image to boot from."
                    exit 1
                fi
            else
                DISK_USED="yes"
            fi
        else
            DISK_USED="yes"
        fi
    fi

    if [ "${DISK_USED}" == "yes" ] && [ "${guest_os}" != "kolibrios" ]; then
        # If there is a disk image that appears to be used do not boot from installation media.
        iso=""
        img=""
    fi

    # Has the status quo been requested?
    if [ "${STATUS_QUO}" == "-snapshot" ]; then
        if [ -z "${img}" ] && [ -z "${iso}" ]; then
            echo "             Existing disk state will be preserved, no writes will be committed."
        fi
    fi

    if [ -n "${iso}" ] && [ -e "${iso}" ]; then
        echo " - Boot ISO: ${iso}"
    elif [ -n "${img}" ] && [ -e "${img}" ]; then
        echo " - Recovery: ${img}"
    fi

    if [ -n "${fixed_iso}" ] && [ -e "${fixed_iso}" ]; then
        echo " - CD-ROM:   ${fixed_iso}"
    fi
}

function configure_display() {
    # Setup the appropriate audio device based on the display output
    # https://www.kraxel.org/blog/2020/01/qemu-sound-audiodev/
    case ${display} in
        cocoa) AUDIO_DEV="coreaudio,id=audio0";;
        none|spice|spice-app) AUDIO_DEV="spice,id=audio0";;
        *) AUDIO_DEV="pa,id=audio0";;
    esac

    # Determine a sane resolution for Linux guests.
    local X_RES="1280"
    local Y_RES="800"
    if [ -n "${width}" ] && [ -n "${height}" ]; then
        local X_RES="${width}"
        local Y_RES="${height}"
    fi

    # https://www.kraxel.org/blog/2019/09/display-devices-in-qemu/
    case ${guest_os} in
        *bsd) DISPLAY_DEVICE="VGA";;
        linux_old|solaris) DISPLAY_DEVICE="vmware-svga";;
        linux)
            case ${display} in
                none|spice|spice-app) DISPLAY_DEVICE="virtio-gpu";;
                *) DISPLAY_DEVICE="virtio-vga";;
            esac;;
        macos)
            # qxl-vga and VGA supports seamless mouse and sane resolutions if only
            # one scanout is used. '-vga none' is added to the QEMU command line
            # to avoid having two scanouts.
            DISPLAY_DEVICE="VGA";;
        windows|windows-server)
            # virtio-gpu "works" with gtk but is limited to 1024x1024 and exhibits other issues
            # https://kevinlocke.name/bits/2021/12/10/windows-11-guest-virtio-libvirt/#video
            case ${display} in
                gtk|none|spice) DISPLAY_DEVICE="qxl-vga";;
                cocoa|sdl|spice-app)  DISPLAY_DEVICE="virtio-vga";;
            esac;;
        *) DISPLAY_DEVICE="qxl-vga";;
    esac

    # Map Quickemu $display to QEMU -display
    case ${display} in
        gtk)        DISPLAY_RENDER="${display},grab-on-hover=on,zoom-to-fit=off,gl=${gl}";;
        none|spice) DISPLAY_RENDER="none";;
        sdl)        DISPLAY_RENDER="${display},gl=${gl}";;
        spice-app)  DISPLAY_RENDER="${display},gl=${gl}";;
        *)          DISPLAY_RENDER="${display}";;
    esac

    # https://www.kraxel.org/blog/2021/05/virtio-gpu-qemu-graphics-update/
    if [ "${gl}" == "on" ] && [ "${DISPLAY_DEVICE}" == "virtio-vga" ]; then
        if [ "${QEMU_VER_SHORT}" -ge 61 ]; then
            DISPLAY_DEVICE="${DISPLAY_DEVICE}-gl"
        else
            DISPLAY_DEVICE="${DISPLAY_DEVICE},virgl=on"
        fi
        echo -n " - Display:  ${display^^}, ${DISPLAY_DEVICE}, GL (${gl}), VirGL (on)"
    else
        echo -n " - Display:  ${display^^}, ${DISPLAY_DEVICE}, GL (${gl}), VirGL (off)"
    fi

    # Build the video configuration
    VIDEO="-device ${DISPLAY_DEVICE}"

    # Try and coerce the display resolution for Linux guests only.
    if [ "${DISPLAY_DEVICE}" != "vmware-svga" ]; then
        VIDEO="${VIDEO},xres=${X_RES},yres=${Y_RES}"
        echo " @ (${X_RES} x ${Y_RES})"
    else
        echo " "
    fi

    # Allocate VRAM to VGA devices
    case ${DISPLAY_DEVICE} in
        bochs-display) VIDEO="${VIDEO},vgamem=67108864";;
        qxl|qxl-vga) VIDEO="${VIDEO},ram_size=65536,vram_size=65536,vgamem_mb=64";;
        ati-vga|cirrus-vga|VGA|vmware-svga) VIDEO="${VIDEO},vgamem_mb=256";;
    esac

    # Configure multiscreen if max_outputs was provided in the .conf file
    if [ -n "${max_outputs}" ]; then
        VIDEO="${VIDEO},max_outputs=${max_outputs}"
    fi

    # Run QEMU with '-vga none' to avoid having two scanouts, one for VGA and
    # another for virtio-vga-gl. This works around a GTK assertion failure and
    # allows seamless mouse in macOS when using the qxl-vga device.
    # https://www.collabora.com/news-and-blog/blog/2021/11/26/venus-on-qemu-enabling-new-virtual-vulkan-driver/
    # https://github.com/quickemu-project/quickemu/issues/222
    VGA="-vga none"

    # Add fullscreen options
    VIDEO="${VGA} ${VIDEO} ${FULLSCREEN}"
}

function configure_audio() {
    # Build the sound hardware configuration
    case ${sound_card} in
        ich9-intel-hda|intel-hda) SOUND="-device ${sound_card} -device ${sound_duplex},audiodev=audio0";;
        usb-audio) SOUND="-device ${sound_card},audiodev=audio0";;
        ac97|es1370|sb16) SOUND="-device ${sound_card},audiodev=audio0";;
        none) SOUND="";;
    esac
    echo " - Sound:    ${sound_card} (${sound_duplex})"
}

function configure_ports() {
    echo -n "" > "${VMDIR}/${VMNAME}.ports"

    if [ -z "${ssh_port}" ]; then
        # Find a free port to expose ssh to the guest
        ssh_port=$(get_port 22220 9)
    fi

    if [ -n "${ssh_port}" ]; then
        echo "ssh,${ssh_port}" >> "${VMDIR}/${VMNAME}.ports"
        NET="${NET},hostfwd=tcp::${ssh_port}-:22"
        echo " - ssh:      On host:  ssh user@localhost -p ${ssh_port}"
    else
        echo " - ssh:      All ssh ports have been exhausted."
    fi

    # Have any port forwards been requested?
    if (( ${#port_forwards[@]} )); then
        echo " - PORTS:    Port forwards requested:"
        for FORWARD in "${port_forwards[@]}"; do
            HOST_PORT=$(echo "${FORWARD}" | cut -d':' -f1)
            GUEST_PORT=$(echo "${FORWARD}" | cut -d':' -f2)
            echo "              - ${HOST_PORT} => ${GUEST_PORT}"
            NET="${NET},hostfwd=tcp::${HOST_PORT}-:${GUEST_PORT}"
            NET="${NET},hostfwd=udp::${HOST_PORT}-:${GUEST_PORT}"
        done
    fi

    if [ "${display}" == "none" ] || [ "${display}" == "spice" ] || [ "${display}" == "spice-app" ]; then
        SPICE="disable-ticketing=on"
        # gl=on can be use with 'spice' too, but only over local connections (not tcp ports)
        if [ "${display}" == "spice-app" ]; then
            SPICE+=",gl=${gl}"
        fi

        # TODO: Don't use ports so local-only connections can be used with gl=on
        if [ -z "${spice_port}" ]; then
            # Find a free port for spice
            spice_port=$(get_port 5930 9)
        fi

        # ALLOW REMOTE ACCESS TO SPICE OVER LAN RATHER THAN JUST LOCALHOST
        if [ -z "${ACCESS}" ]; then
            SPICE_ADDR="127.0.0.1"
        else
            if [ "${ACCESS}" == "remote" ]; then
                SPICE_ADDR=""
            elif [ "${ACCESS}" == "local" ]; then
                SPICE_ADDR="127.0.0.1"
            else
                SPICE_ADDR="${ACCESS}"
            fi
        fi

        if [ -z "${spice_port}" ]; then
            echo " - SPICE:    All SPICE ports have been exhausted."
            if [ "${display}" == "none" ] || [ "${display}" == "spice" ] || [ "${display}" == "spice-app" ]; then
                echo "             ERROR! Requested SPICE display, but no SPICE ports are free."
                exit 1
            fi
        else
            if [ "${display}" == "spice-app" ]; then
                echo " - SPICE:    Enabled"
            else
                echo "spice,${spice_port}" >> "${VMDIR}/${VMNAME}.ports"
                echo -n " - SPICE:    On host:  spicy --title \"${VMNAME}\" --port ${spice_port}"
                if [ "${guest_os}" != "macos" ] && [ -n "${PUBLIC}" ]; then
                    echo -n " --spice-shared-dir ${PUBLIC}"
                fi
                echo "${FULLSCREEN}"
                SPICE="${SPICE},port=${spice_port},addr=${SPICE_ADDR}"
            fi
        fi
    fi
}

function configure_file_sharing() {
    if [ -n "${PUBLIC}" ]; then
        # WebDAV
        case ${guest_os} in
            macos)
                if [ "${display}" == "none" ] || [ "${display}" == "spice" ] || [ "${display}" == "spice-app" ]; then
                    # Reference: https://gitlab.gnome.org/GNOME/phodav/-/issues/5
                    echo " - WebDAV:   On guest: build spice-webdavd (https://gitlab.gnome.org/GNOME/phodav/-/merge_requests/24)"
                    echo " - WebDAV:   On guest: Finder -> Connect to Server -> http://localhost:9843/"
                fi;;
            *) echo " - WebDAV:   On guest: dav://localhost:9843/";;
        esac

        # 9P
        if [ "${guest_os}" != "windows" ] || [ "${guest_os}" == "windows-server" ]; then
            echo -n " - 9P:       On guest: "
            if [ "${guest_os}" == "linux" ]; then
                echo "sudo mount -t 9p -o trans=virtio,version=9p2000.L,msize=104857600 ${PUBLIC_TAG} ~/$(basename "${PUBLIC}")"
            elif [ "${guest_os}" == "macos" ]; then
                # PUBLICSHARE needs to be world writeable for seamless integration with
                # macOS. Test if it is world writeable, and prompt what to do if not.
                echo "sudo mount_9p ${PUBLIC_TAG}"
                if [ "${PUBLIC_PERMS}" != "drwxrwxrwx" ]; then
                    echo " - 9P:       On host:  chmod 777 ${PUBLIC}"
                    echo "             Required for macOS integration 👆"
                fi
            fi
        fi

        # SMB
        if [ -x "$(command -v smbd)" ]; then
            NET+=",smb=${PUBLIC}"
            echo " - smbd:     On guest: smb://10.0.2.4/qemu"
        fi
    fi
}

function configure_tpm() {
    # Start TPM
    if [ "${tpm}" == "on" ]; then
        local tpm_args=()
        # shellcheck disable=SC2054
        tpm_args+=(socket
            --ctrl type=unixio,path="${VMDIR}/${VMNAME}.swtpm-sock"
            --terminate
            --tpmstate dir="${VMDIR}"
            --tpm2)
        echo "${SWTPM} ${tpm_args[*]} &" >> "${VMDIR}/${VMNAME}.sh"
        ${SWTPM} "${tpm_args[@]}" >> "${VMDIR}/${VMNAME}.log" &
        echo " - TPM:      ${VMDIR}/${VMNAME}.swtpm-sock (${!})"
        sleep 0.25
    fi
}

function vm_boot() {
    AUDIO_DEV=""
    BALLOON="-device virtio-balloon"
    BOOT_STATUS=""
    CPU=""
    DISK_USED=""
    DISPLAY_DEVICE=""
    DISPLAY_RENDER=""
    EFI_CODE=""
    EFI_VARS=""
    GUEST_CPU_CORES=""
    GUEST_CPU_LOGICAL_CORES=""
    GUEST_CPU_THREADS=""
    HOST_CPU_CORES=""
    HOST_CPU_SMT=""
    HOST_CPU_SOCKETS=""
    HOST_CPU_VENDOR=""
    GUEST_TWEAKS=""
    KERNEL_NAME="Unknown"
    KERNEL_NODE=""
    KERNEL_VER="?"
    OS_RELEASE="Unknown OS"
    MACHINE_TYPE="${MACHINE_TYPE:-q35}"
    MAC_BOOTLOADER=""
    MAC_MISSING=""
    MAC_DISK_DEV="${MAC_DISK_DEV:-ide-hd,bus=ahci.2}"
    NET_DEVICE="${NET_DEVICE:-virtio-net}"
    SOUND=""
    SPICE=""
    SMM="${SMM:-off}"
    local TEMP_PORT=""
    USB_HOST_PASSTHROUGH_CONTROLLER="qemu-xhci"
    VGA=""
    VIDEO=""

    KERNEL_NAME="$(uname -s)"
    KERNEL_NODE="$(uname -n | cut -d'.' -f 1)"
    KERNEL_VER="$(uname -r)"

    if [ "${OS_KERNEL}" == "Darwin" ]; then
        # Get macOS product name and version using swvers
        if [ -x "$(command -v sw_vers)" ]; then
            OS_RELEASE="$(sw_vers -productName) $(sw_vers -productVersion)"
        fi
    elif [ -e /etc/os-release ]; then
        OS_RELEASE=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
    fi

    echo "Quickemu ${VERSION} using ${QEMU} v${QEMU_VER_LONG}"
    echo " - Host:     ${OS_RELEASE} running ${KERNEL_NAME} ${KERNEL_VER} ${KERNEL_NODE}"

    # Force to lowercase.
    boot=${boot,,}
    guest_os=${guest_os,,}
    args=()
    # Set the hostname of the VM
    NET="user,hostname=${VMNAME}"

    configure_cpu
    configure_ram
    configure_bios
    configure_os_quirks
    configure_storage
    configure_display
    configure_audio
    configure_ports
    configure_file_sharing
    configure_usb
    configure_tpm

    echo "#!/usr/bin/env bash" > "${VMDIR}/${VMNAME}.sh"

    # Changing process name is not supported on macOS
    if [ "${OS_KERNEL}" == "Linux" ]; then
        # shellcheck disable=SC2054,SC2206,SC2140
        args+=(-name ${VMNAME},process=${VMNAME})
    fi
    # shellcheck disable=SC2054,SC2206,SC2140
    args+=(-machine ${MACHINE_TYPE},smm=${SMM},vmport=off,accel=${QEMU_ACCEL} ${GUEST_TWEAKS}
        ${CPU} ${SMP}
        -m ${RAM_VM} ${BALLOON}
        -rtc base=localtime,clock=host,driftfix=slew
        -pidfile "${VMDIR}/${VMNAME}.pid")

    # shellcheck disable=SC2206
    args+=(${VIDEO} -display ${DISPLAY_RENDER})
    # Only enable SPICE is using SPICE display
    if [ "${display}" == "none" ] || [ "${display}" == "spice" ] || [ "${display}" == "spice-app" ]; then
        # shellcheck disable=SC2054
        args+=(-spice "${SPICE}"
            -device virtio-serial-pci
            -chardev socket,id=agent0,path="${VMDIR}/${VMNAME}-agent.sock",server=on,wait=off
            -device virtserialport,chardev=agent0,name=org.qemu.guest_agent.0
            -chardev spicevmc,id=vdagent0,name=vdagent
            -device virtserialport,chardev=vdagent0,name=com.redhat.spice.0
            -chardev spiceport,id=webdav0,name=org.spice-space.webdav.0
            -device virtserialport,chardev=webdav0,name=org.spice-space.webdav.0)
    fi

    # shellcheck disable=SC2054
    args+=(-device virtio-rng-pci,rng=rng0 -object rng-random,id=rng0,filename=/dev/urandom)

    # macOS doesn't support SPICE
    if [ "${OS_KERNEL}" == "Linux" ]; then
        # shellcheck disable=SC2054
        args+=(-device "${USB_HOST_PASSTHROUGH_CONTROLLER}",id=spicepass
            -chardev spicevmc,id=usbredirchardev1,name=usbredir
            -device usb-redir,chardev=usbredirchardev1,id=usbredirdev1
            -chardev spicevmc,id=usbredirchardev2,name=usbredir
            -device usb-redir,chardev=usbredirchardev2,id=usbredirdev2
            -chardev spicevmc,id=usbredirchardev3,name=usbredir
            -device usb-redir,chardev=usbredirchardev3,id=usbredirdev3
            -device pci-ohci,id=smartpass
            -device usb-ccid)

        if ${QEMU} -device help | grep -q "passthrough smartcard"; then
            # shellcheck disable=SC2054
            args+=(-chardev spicevmc,id=ccid,name=smartcard
                  -device ccid-card-passthru,chardev=ccid)
        else
            echo " - WARNING!  ${QEMU} or SPICE was not compiled with support for smartcard devices"
        fi
    fi

    # setup usb-controller
    if [ "${usb_controller}" == "ehci" ]; then
        # shellcheck disable=SC2054
        args+=(-device usb-ehci,id=input)
    elif [ "${usb_controller}" == "xhci" ]; then
        # shellcheck disable=SC2054
        args+=(-device qemu-xhci,id=input)
    elif [ "${usb_controller}" == "none" ]; then
        # add nothing
        :
    else
        echo " - WARNING!  Unknown usb-controller value: '${usb_controller}'"
    fi

    # setup keyboard
    # @INFO: must be set after usb-controller
    if [ "${keyboard}" == "usb" ]; then
        # shellcheck disable=SC2054
        args+=(-device usb-kbd,bus=input.0)
    elif [ "${keyboard}" == "virtio" ]; then
        # shellcheck disable=SC2054
        args+=(-device virtio-keyboard)
    elif [ "${keyboard}" == "ps2" ]; then
        # add nothing, default is ps/2 keyboard
        :
    else
        echo " - WARNING!  Unknown keyboard value: '${keyboard}'; Fallback to ps2"
    fi

    # setup keyboard_layout
    # @INFO: When using the VNC display, you must use the -k parameter to set the keyboard layout if you are not using en-us.
    if [ -n "${keyboard_layout}" ]; then
        args+=(-k "${keyboard_layout}")
    fi

    # Braille requires SDL, so disable for macOS
    if [ -n "${BRAILLE}" ] && [ "${OS_KERNEL}" == "Linux" ]; then
        if ${QEMU} -chardev help | grep -q braille; then
            # shellcheck disable=SC2054
            #args+=(-chardev braille,id=brltty
            #       -device usb-braille,id=usbbrl,chardev=brltty)
            args+=(-usbdevice braille)
        else
            echo " - WARNING!  ${QEMU} does not support -chardev braille "
        fi
    fi

    # setup mouse
    # @INFO: must be set after usb-controller
    if [ "${mouse}" == "usb" ]; then
        # shellcheck disable=SC2054
        args+=(-device usb-mouse,bus=input.0)
    elif [ "${mouse}" == "tablet" ]; then
        # shellcheck disable=SC2054
        args+=(-device usb-tablet,bus=input.0)
    elif [ "${mouse}" == "virtio" ]; then
        # shellcheck disable=SC2054
        args+=(-device virtio-mouse)
    elif [ "${mouse}" == "ps2" ]; then
        # add nothing, default is ps/2 mouse
        :
    else
        echo " - WARNING!  Unknown mouse value: '${mouse}'; Falling back to ps2"
    fi

    # setup audio
    # @INFO: must be set after usb-controller; in case usb-audio is used
    # shellcheck disable=SC2206
    args+=(-audiodev ${AUDIO_DEV} ${SOUND})

    # $bridge backwards compatibility for Quickemu <= 4.0
    if [ -n "${bridge}" ]; then
        network="${bridge}"
    fi

    if [ "${network}" == "none" ]; then
        # Disable all networking
        echo " - Network:  Disabled"
        args+=(-nic none)
    elif [ "${network}" == "restrict" ]; then
        echo " - Network:  Restricted (${NET_DEVICE})"
        # shellcheck disable=SC2054,SC2206
        args+=(-device ${NET_DEVICE},netdev=nic -netdev ${NET},restrict=y,id=nic)
    elif [ -n "${network}" ]; then
        # Enable bridge mode networking
        echo " - Network:  Bridged (${network})"

        # If a persistent MAC address is provided, use it.
        local MAC=""
        if [ -n "${macaddr}" ]; then
            MAC=",mac=${macaddr}"
        fi

        # shellcheck disable=SC2054,SC2206
        args+=(-nic bridge,br=${network},model=virtio-net-pci${MAC})
    else
        echo " - Network:  User (${NET_DEVICE})"
        # shellcheck disable=SC2054,SC2206
        args+=(-device ${NET_DEVICE},netdev=nic -netdev ${NET},id=nic)
    fi

    # Add the disks
    # - https://turlucode.com/qemu-disk-io-performance-comparison-native-or-threads-windows-10-version/
    if [[ "${boot}" == *"efi"* ]]; then
        # shellcheck disable=SC2054
        args+=(-global driver=cfi.pflash01,property=secure,value=on
            -drive if=pflash,format=raw,unit=0,file="${EFI_CODE}",readonly=on
            -drive if=pflash,format=raw,unit=1,file="${EFI_VARS}")
    fi

    if [ -n "${iso}" ] && [ "${guest_os}" == "freedos" ]; then
        # FreeDOS reboots after partitioning the disk, and QEMU tries to boot from disk after first restart
        # This flag sets the boot order to cdrom,disk. It will persist until powering down the VM
        args+=(-boot order=dc)
    elif [ -n "${iso}" ] && [ "${guest_os}" == "kolibrios" ]; then
        # Since there is bug (probably) in KolibriOS: cdrom indexes 0 or 1 make system show an extra unexisting iso, so we use index=2
        # shellcheck disable=SC2054
        args+=(-drive media=cdrom,index=2,file="${iso}")
        iso=""
    elif [ -n "${iso}" ] && [ "${guest_os}" == "reactos" ]; then
        # https://reactos.org/wiki/QEMU
        # shellcheck disable=SC2054
        args+=(-boot order=d
            -drive if=ide,index=2,media=cdrom,file="${iso}")
        iso=""
    elif [ -n "${iso}" ] && [ "${guest_os}" == "windows" ] && [ -e "${VMDIR}/unattended.iso" ]; then
        # Attach the unattended configuration to Windows guests when booting from ISO
        # shellcheck disable=SC2054
        args+=(-drive media=cdrom,index=2,file="${VMDIR}/unattended.iso")
    fi

    if [ -n "${floppy}" ]; then
        # shellcheck disable=SC2054
        args+=(-drive if=floppy,format=raw,file="${floppy}")
    fi

    if [ -n "${iso}" ]; then
        # shellcheck disable=SC2054
        args+=(-drive media=cdrom,index=0,file="${iso}")
    fi

    if [ -n "${fixed_iso}" ]; then
        # shellcheck disable=SC2054
        args+=(-drive media=cdrom,index=1,file="${fixed_iso}")
    fi

    if [ "${guest_os}" == "macos" ]; then
        # shellcheck disable=SC2054
        args+=(-device ahci,id=ahci
            -device ide-hd,bus=ahci.0,drive=BootLoader,bootindex=0
            -drive id=BootLoader,if=none,format=qcow2,file="${MAC_BOOTLOADER}")

        if [ -n "${img}" ]; then
            # shellcheck disable=SC2054
            args+=(-device ide-hd,bus=ahci.1,drive=RecoveryImage
                -drive id=RecoveryImage,if=none,format=raw,file="${img}")
        fi

        # shellcheck disable=SC2054,SC2206
        args+=(-device ${MAC_DISK_DEV},drive=SystemDisk
            -drive id=SystemDisk,if=none,format=qcow2,file="${disk_img}" ${STATUS_QUO})
    elif [ "${guest_os}" == "kolibrios" ]; then
        # shellcheck disable=SC2054,SC2206
        args+=(-device ahci,id=ahci
            -device ide-hd,bus=ahci.0,drive=SystemDisk
            -drive id=SystemDisk,if=none,format=qcow2,file="${disk_img}" ${STATUS_QUO})

    elif [ "${guest_os}" == "batocera" ] ; then
        # shellcheck disable=SC2054,SC2206
        args+=(-device virtio-blk-pci,drive=BootDisk
            -drive id=BootDisk,if=none,format=raw,file="${img}"
            -device virtio-blk-pci,drive=SystemDisk
            -drive id=SystemDisk,if=none,format=qcow2,file="${disk_img}" ${STATUS_QUO})

    elif [ "${guest_os}" == "reactos" ]; then
        # https://reactos.org/wiki/QEMU
        # shellcheck disable=SC2054,SC2206
        args+=(-drive if=ide,index=0,media=disk,file="${disk_img}")

    elif [ "${guest_os}" == "windows-server" ]; then
        # shellcheck disable=SC2054,SC2206
        args+=(-device ide-hd,drive=SystemDisk
            -drive id=SystemDisk,if=none,format=qcow2,file="${disk_img}" ${STATUS_QUO})

    else
        # shellcheck disable=SC2054,SC2206
        args+=(-device virtio-blk-pci,drive=SystemDisk
            -drive id=SystemDisk,if=none,format=${disk_format},file="${disk_img}" ${STATUS_QUO})
    fi

    # https://wiki.qemu.org/Documentation/9psetup
    # https://askubuntu.com/questions/772784/9p-libvirt-qemu-share-modes
    if [ "${guest_os}" != "windows" ] || [ "${guest_os}" == "windows-server" ] && [ -n "${PUBLIC}" ]; then
        # shellcheck disable=SC2054
        args+=(-fsdev local,id=fsdev0,path="${PUBLIC}",security_model=mapped-xattr
            -device virtio-9p-pci,fsdev=fsdev0,mount_tag="${PUBLIC_TAG}")
    fi

    if [ -n "${USB_PASSTHROUGH}" ]; then
        # shellcheck disable=SC2054,SC2206
        args+=(-device ${USB_HOST_PASSTHROUGH_CONTROLLER},id=hostpass
            ${USB_PASSTHROUGH})
    fi

    if [ "${tpm}" == "on" ] && [ -S "${VMDIR}/${VMNAME}.swtpm-sock" ]; then
        # shellcheck disable=SC2054
        args+=(-chardev socket,id=chrtpm,path="${VMDIR}/${VMNAME}.swtpm-sock"
            -tpmdev emulator,id=tpm0,chardev=chrtpm
            -device tpm-tis,tpmdev=tpm0)
    fi

    if [ "${monitor}" == "none" ]; then
        args+=(-monitor none)
        echo " - Monitor:  (off)"
    elif [ "${monitor}" == "telnet" ]; then
        # Find a free port to expose monitor-telnet to the guest
        TEMP_PORT="$(get_port "${monitor_telnet_port}" 9)"
        if [ -z "${TEMP_PORT}" ]; then
            echo " - Monitor:  All Monitor-Telnet ports have been exhausted."
        else
            monitor_telnet_port="${TEMP_PORT}"
            # shellcheck disable=SC2054
            args+=(-monitor telnet:"${monitor_telnet_host}:${monitor_telnet_port}",server,nowait)
            echo " - Monitor:  On host:  telnet ${monitor_telnet_host} ${monitor_telnet_port}"
            echo "monitor-telnet,${monitor_telnet_port},${monitor_telnet_host}" >> "${VMDIR}/${VMNAME}.ports"
        fi
    elif [ "${monitor}" == "socket" ]; then
        # shellcheck disable=SC2054,SC2206
        args+=(-monitor unix:${SOCKET_MONITOR},server,nowait)
        if command -v socat &>/dev/null; then
            echo " - Monitor:  On host:  socat -,echo=0,icanon=0 unix-connect:${SOCKET_MONITOR}"
        elif command -v nc &>/dev/null; then
            echo " - Monitor:  On host:  nc -U \"${SOCKET_MONITOR}\""
        fi
    else
        echo "ERROR! \"${monitor}\" is an unknown monitor option."
        exit 1
    fi

    if [ "${serial}" == "none" ]; then
        args+=(-serial none)
        echo " - Serial:   (off)"
    elif [ "${serial}" == "telnet" ]; then
        # Find a free port to expose serial-telnet to the guest
        TEMP_PORT="$(get_port "${serial_telnet_port}" 9)"
        if [ -z "${TEMP_PORT}" ]; then
            echo " - Serial:   All Serial Telnet ports have been exhausted."
        else
            serial_telnet_port="${TEMP_PORT}"
            # shellcheck disable=SC2054,SC2206
            args+=(-serial telnet:${serial_telnet_host}:${serial_telnet_port},server,nowait)
            echo " - Serial:   On host:  telnet ${serial_telnet_host} ${serial_telnet_port}"
            echo "serial-telnet,${serial_telnet_port},${serial_telnet_host}" >> "${VMDIR}/${VMNAME}.ports"
        fi
    elif [ "${serial}" == "socket" ]; then
        # shellcheck disable=SC2054,SC2206
        args+=(-serial unix:${SOCKET_SERIAL},server,nowait)
        if command -v socat &>/dev/null; then
            echo " - Serial:   On host:  socat -,echo=0,icanon=0 unix-connect:${SOCKET_SERIAL}"
        elif command -v nc &>/dev/null; then
            echo " - Serial:   On host:  nc -U \"${SOCKET_SERIAL}\""
        fi
    else
        echo "ERROR! \"${serial}\" is an unknown serial option."
        exit 1
    fi

    if [ -n "${extra_args}" ]; then
        # shellcheck disable=SC2206
        args+=(${extra_args})
    fi

    # The OSK parameter contains parenthesis, they need to be escaped in the shell
    # scripts. The vendor name, Quickemu Project, contains a space. It needs to be
    # double-quoted.
    SHELL_ARGS="${args[*]}"
    SHELL_ARGS="${SHELL_ARGS//\(/\\(}"
    SHELL_ARGS="${SHELL_ARGS//)/\\)}"
    SHELL_ARGS="${SHELL_ARGS//Quickemu Project/\"Quickemu Project\"}"

    if [ -z "${VM_PID}" ]; then
        echo "${QEMU}" "${SHELL_ARGS}" "2>/dev/null" >> "${VMDIR}/${VMNAME}.sh"
        sed -i -e 's/ -/ \\\n    -/g' "${VMDIR}/${VMNAME}.sh"
        ${QEMU} "${args[@]}" &> "${VMDIR}/${VMNAME}.log" &
        VM_PID=$!
        sleep 0.25
        if kill -0 "${VM_PID}" 2>/dev/null; then
            echo " - Process:  Started ${VM} as ${VMNAME} (${VM_PID})"
        else
            echo " - Process:  ERROR! Failed to start ${VM} as ${VMNAME}"
            rm -f "${VMDIR}/${VMNAME}.pid"
            echo && cat "${VMDIR}/${VMNAME}.log"
            exit 1
        fi
    fi
}

function start_viewer {
    errno=0
    if [ "${viewer}" != "none" ]; then
        # If output is 'none' then SPICE was requested.
        if [ "${display}" == "spice" ]; then
            if [ "${viewer}" == "remote-viewer" ]; then
                # show via viewer: remote-viewer
                if [ -n "${PUBLIC}" ]; then
                    echo " - Viewer:   ${viewer} --title \"${VMNAME}\" --spice-shared-dir \"${PUBLIC}\" ${FULLSCREEN} \"spice://localhost:${spice_port}\" >/dev/null 2>&1 &"
                    ${viewer} --title "${VMNAME}" --spice-shared-dir "${PUBLIC}" ${FULLSCREEN} "spice://localhost:${spice_port}" >/dev/null 2>&1 &
                    errno=$?
                else
                    echo " - Viewer:   ${viewer} --title \"${VMNAME}\" ${FULLSCREEN} \"spice://localhost:${spice_port}\" >/dev/null 2>&1 &"
                    ${viewer} --title "${VMNAME}" ${FULLSCREEN} "spice://localhost:${spice_port}" >/dev/null 2>&1 &
                    errno=$?
                fi
            elif [ "${viewer}" == "spicy" ]; then
                # show via viewer: spicy
                if [ -n "${PUBLIC}" ]; then
                    echo " - Viewer:   ${viewer} --title \"${VMNAME}\" --port \"${spice_port}\" --spice-shared-dir \"${PUBLIC}\" \"${FULLSCREEN}\" >/dev/null 2>&1 &"
                    ${viewer} --title "${VMNAME}" --port "${spice_port}" --spice-shared-dir "${PUBLIC}" "${FULLSCREEN}" >/dev/null 2>&1 &
                    errno=$?
                else
                    echo " - Viewer:   ${viewer} --title \"${VMNAME}\" --port \"${spice_port}\" \"${FULLSCREEN}\" >/dev/null 2>&1 &"
                    ${viewer} --title "${VMNAME}" --port "${spice_port}" "${FULLSCREEN}" >/dev/null 2>&1 &
                    errno=$?
                fi
            fi
            if [ ${errno} -ne 0 ]; then
                echo "WARNING! Could not start viewer (${viewer}) Err: ${errno}"
            fi
        fi
    fi
}

function shortcut_create {
    local dirname="${HOME}/.local/share/applications"
    local filename="${HOME}/.local/share/applications/${VMNAME}.desktop"
    echo "Creating ${VMNAME} desktop shortcut file"

    if [ ! -d "${dirname}" ]; then
        mkdir -p "${dirname}"
    fi
    cat << EOF > "${filename}"
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Exec=$(basename "${0}") --vm ${VM} ${SHORTCUT_OPTIONS}
Path=${VMPATH}
Name=${VMNAME}
Icon=qemu
EOF
    echo " - ${filename} created."
}

function usage() {
    echo "             _      _"
    echo "  __ _ _   _(_) ___| | _____ _ __ ___  _   _"
    echo " / _' | | | | |/ __| |/ / _ \ '_ ' _ \| | | |"
    echo "| (_| | |_| | | (__|   <  __/ | | | | | |_| |"
    echo " \__, |\__,_|_|\___|_|\_\___|_| |_| |_|\__,_|"
    echo "    |_| v${VERSION}, using qemu ${QEMU_VER_LONG}"
    echo "--------------------------------------------------------------------------------"
    echo " Project - https://github.com/quickemu-project/quickemu"
    echo " Discord - https://wimpysworld.io/discord"
    echo "--------------------------------------------------------------------------------"
    echo
    echo "Usage"
    echo "  ${LAUNCHER} --vm ubuntu.conf <arguments>"
    echo
    echo "Arguments"
    echo "  --access                          : Enable remote spice access support. 'local' (default), 'remote', 'clientipaddress'"
    echo "  --braille                         : Enable braille support. Requires SDL."
    echo "  --delete-disk                     : Delete the disk image and EFI variables"
    echo "  --delete-vm                       : Delete the entire VM and its configuration"
    echo "  --display                         : Select display backend. 'sdl' (default), 'cocoa', 'gtk', 'none', 'spice' or 'spice-app'"
    echo "  --fullscreen                      : Starts VM in full screen mode (Ctl+Alt+f to exit)"
    echo "  --ignore-msrs-always              : Configure KVM to always ignore unhandled machine-specific registers"
    echo "  --kill                            : Kill the VM process if it is running"
    echo "  --offline                         : Override all network settings and start the VM offline"
    echo "  --shortcut                        : Create a desktop shortcut"
    echo "  --snapshot apply <tag>            : Apply/restore a snapshot."
    echo "  --snapshot create <tag>           : Create a snapshot."
    echo "  --snapshot delete <tag>           : Delete a snapshot."
    echo "  --snapshot info                   : Show disk/snapshot info."
    echo "  --status-quo                      : Do not commit any changes to disk/snapshot."
    echo "  --viewer <viewer>                 : Choose an alternative viewer. @Options: 'spicy' (default), 'remote-viewer', 'none'"
    echo "  --width <width>                   : Set VM screen width; requires '--height'"
    echo "  --height <height>                 : Set VM screen height; requires '--width'"
    echo "  --ssh-port <port>                 : Set SSH port manually"
    echo "  --spice-port <port>               : Set SPICE port manually"
    echo "  --public-dir <path>               : Expose share directory. @Options: '' (default: xdg-user-dir PUBLICSHARE), '<directory>', 'none'"
    echo "  --monitor <type>                  : Set monitor connection type. @Options: 'socket' (default), 'telnet', 'none'"
    echo "  --monitor-telnet-host <ip/host>   : Set telnet host for monitor. (default: 'localhost')"
    echo "  --monitor-telnet-port <port>      : Set telnet port for monitor. (default: '4440')"
    echo "  --monitor-cmd <cmd>               : Send command to monitor if available. (Example: system_powerdown)"
    echo "  --serial <type>                   : Set serial connection type. @Options: 'socket' (default), 'telnet', 'none'"
    echo "  --serial-telnet-host <ip/host>    : Set telnet host for serial. (default: 'localhost')"
    echo "  --serial-telnet-port <port>       : Set telnet port for serial. (default: '6660')"
    echo "  --keyboard <type>                 : Set keyboard. @Options: 'usb' (default), 'ps2', 'virtio'"
    echo "  --keyboard_layout <layout>        : Set keyboard layout: 'en-us' (default)"
    echo "  --mouse <type>                    : Set mouse. @Options: 'tablet' (default), 'ps2', 'usb', 'virtio'"
    echo "  --usb-controller <type>           : Set usb-controller. @Options: 'ehci' (default), 'xhci', 'none'"
    echo "  --sound-card <type>               : Set sound card. @Options: 'intel-hda' (default), 'ac97', 'es1370', 'sb16', 'usb-audio', 'none'"
    echo "  --sound-duplex <type>             : Set sound card duplex. @Options: 'hda-micro' (default: speaker/mic), 'hda-duplex' (line-in/line-out), 'hda-output' (output-only)"
    echo "  --extra_args <arguments>          : Pass additional arguments to qemu"
    echo "  --version                         : Print version"
}

function display_param_check() {
    # Braille support requires SDL. Override $display if braille was requested.
    if [ -n "${BRAILLE}" ]; then
        display="sdl"
    fi

    if [ "${OS_KERNEL}" == "Darwin" ]; then
        if [ "${display}" != "cocoa" ] && [ "${display}" != "none" ]; then
          echo "ERROR! Requested output '${display}' but only 'cocoa' and 'none' are avalible on macOS."
          exit 1
        fi
    else
        if [ "${display}" != "gtk" ] && [ "${display}" != "none" ] && [ "${display}" != "sdl" ] && [ "${display}" != "spice" ] && [ "${display}" != "spice-app" ]; then
            echo "ERROR! Requested output '${display}' is not recognised."
            exit 1
        fi
    fi

    # Set the default 3D acceleration.
    if [ -z "${gl}" ]; then
        if command -v glxinfo &>/dev/null; then
            GLSL_VER=$(glxinfo | grep "OpenGL ES GLSL" | awk '{print $NF}')
            case ${GLSL_VER} in
                1*|2*) gl="off";;
                *) gl="on";;
            esac
        else
            gl="on"
        fi
    fi

    # Disable GL for cocoa
    # Enable grab-on-hover for SDL: https://github.com/quickemu-project/quickemu/issues/541
    case "${display}" in
        cocoa) gl="off";;
        sdl) export SDL_MOUSE_FOCUS_CLICKTHROUGH=1;;
    esac
}

function ports_param_check() {
    if [ -n "${ssh_port}" ] && ! is_numeric "${ssh_port}"; then
        echo "ERROR: ssh_port must be a number!"
        exit 1
    fi

    if [ -n "${spice_port}" ] && ! is_numeric "${spice_port}"; then
        echo "ERROR: spice_port must be a number!"
        exit 1
    fi

    if [ -n "${monitor_telnet_port}" ] && ! is_numeric "${monitor_telnet_port}"; then
        echo "ERROR: telnet port must be a number!"
        exit 1
    fi

    if [ -n "${serial_telnet_port}" ] && ! is_numeric "${serial_telnet_port}"; then
        echo "ERROR: serial port must be a number!"
        exit 1
    fi
}

function sound_card_param_check() {
    if [ "${sound_card}" != "ac97" ] && [ "${sound_card}" != "es1370" ] && [ "${sound_card}" != "ich9-intel-hda" ] && [ "${sound_card}" != "intel-hda" ] && [ "${sound_card}" != "sb16" ] && [ "${sound_card}" != "usb-audio" ] && [ "${sound_card}" != "none" ]; then
        echo "ERROR! Requested sound card '${sound_card}' is not recognised."
        exit 1
    fi

    # USB audio requires xhci controller
    if [ "${sound_card}" == "usb-audio" ]; then
        usb_controller="xhci";
    fi

    #name "hda-duplex", bus HDA, desc "HDA Audio Codec, duplex (line-out, line-in)"
    #name "hda-micro", bus HDA, desc "HDA Audio Codec, duplex (speaker, microphone)"
    #name "hda-output", bus HDA, desc "HDA Audio Codec, output-only (line-out)"
    if [ "${sound_duplex}" != "hda-duplex" ] && [ "${sound_duplex}" != "hda-micro" ] && [ "${sound_duplex}" != "hda-output" ]; then
        echo "ERROR! Requested sound duplex '${sound_duplex}' is not recognised."
        exit 1
    fi
}

function tpm_param_check() {
    if [ "${tpm}" == "on" ]; then
        SWTPM=$(command -v swtpm)
        if [ ! -e "${SWTPM}" ]; then
            echo "ERROR! TPM is enabled, but swtpm was not found."
            exit 1
        fi
    fi
}

function viewer_param_check() {
    if [ "${OS_KERNEL}" == "Darwin" ]; then
        return
    fi

    if [ "${viewer}" != "none" ] && [ "${viewer}" != "spicy" ] && [ "${viewer}" != "remote-viewer" ]; then
        echo "ERROR! Requested viewer '${viewer}' is not recognised."
        exit 1
    fi
    if [ "${viewer}" == "spicy" ] && ! command -v spicy &>/dev/null; then
        echo "ERROR! Requested 'spicy' as viewer, but 'spicy' is not installed."
        exit 1
    elif [ "${viewer}" == "remote-viewer" ] && ! command -v remote-viewer &>/dev/null; then
        echo "ERROR! Requested 'remote-viewer' as viewer, but 'remote-viewer' is not installed."
        exit 1
    fi
}

function fileshare_param_check() {
    if [ "${PUBLIC}" == "none" ]; then
        PUBLIC=""
    else
        # PUBLICSHARE is the only directory exposed to guest VMs for file
        # sharing via 9P, spice-webdavd and Samba. This path is not configurable.
        if [ -z "${PUBLIC}" ]; then
            if command -v xdg-user-dir &>/dev/null; then
                PUBLIC=$(xdg-user-dir PUBLICSHARE)
            elif [ -d "${HOME}/Public" ]; then
                PUBLIC="${HOME}/Public"
            fi
        fi

        if [ ! -d "${PUBLIC}" ]; then
            echo " - WARNING! Public directory: '${PUBLIC}' doesn't exist!"
        else
            PUBLIC_TAG="Public-${USER,,}"
            PUBLIC_PERMS=$(${STAT}  -c "%A" "${PUBLIC}")
        fi
    fi
}

function parse_ports_from_file {
    local FILE="${VMDIR}/${VMNAME}.ports"
    local host_name=""
    local port_name=""
    local port_number=""

    # Loop over each line in the file
    while IFS= read -r CONF || [ -n "${CONF}" ]; do
        # parse ports
        port_name=$(echo "${CONF}" | cut -d',' -f 1)
        port_number=$(echo "${CONF}" | cut -d',' -f 2)
        host_name=$(echo "${CONF}" | awk 'FS="," {print $3,"."}')

        if [ "${port_name}" == "ssh" ]; then
            ssh_port="${port_number}"
        elif [ "${port_name}" == "spice" ]; then
            spice_port="${port_number}"
        elif [ "${port_name}" == "monitor-telnet" ]; then
            monitor_telnet_port="${port_number}"
            monitor_telnet_host="${host_name}"
        elif [ "${port_name}" == "serial-telnet" ]; then
            serial_telnet_port="${port_number}"
            serial_telnet_host="${host_name}"
        fi
    done < "${FILE}"
}

function is_numeric {
    [[ "$1" =~ ^[0-9]+$ ]]
}

function monitor_send_cmd {
    local MSG="${1}"

    if [ -z "${MSG}" ]; then
        echo "WARNING! Send to QEMU-Monitor: Message empty!"
        return 1
    fi

    case "${monitor}" in
        socket)
            echo -e " - Sending:  via socket ${MSG}"
            echo -e "${MSG}" | socat -,shut-down unix-connect:"${SOCKET_MONITOR}" > /dev/null 2>&1;;
        telnet)
            echo -e " - Sending:  via telnet ${MSG}"
            echo -e "${MSG}" | socat - tcp:"${monitor_telnet_host}":"${monitor_telnet_port}" > /dev/null 2>&1;;
        *)
            echo "WARNING! No qemu-monitor channel available - Couldn't send message to monitor!"
            return 1;;
    esac

    return 0
}

### MAIN

# Lowercase variables are used in the VM config file only
boot="efi"
cpu_cores=""
disk_format="${disk_format:-qcow2}"
disk_img="${disk_img:-}"
disk_size="${disk_size:-16G}"
display="${display:-sdl}"
extra_args="${extra_args:-}"
fixed_iso=""
floppy=""
guest_os="linux"
img=""
iso=""
macaddr=""
macos_release=""
network=""
port_forwards=()
preallocation="off"
ram=""
secureboot="off"
tpm="off"
usb_devices=()
viewer="${viewer:-spicy}"
width="${width:-}"
height="${height:-}"
ssh_port="${ssh_port:-}"
spice_port="${spice_port:-}"
monitor="${monitor:-socket}"
monitor_telnet_port="${monitor_telnet_port:-4440}"
monitor_telnet_host="${monitor_telnet_host:-localhost}"
serial="${serial:-socket}"
serial_telnet_port="${serial_telnet_port:-6660}"
serial_telnet_host="${serial_telnet_host:-localhost}"
# options: ehci (USB2.0), xhci (USB3.0)
usb_controller="${usb_controller:-ehci}"
keyboard="${keyboard:-usb}"
keyboard_layout="${keyboard_layout:-en-us}"
mouse="${mouse:-tablet}"
sound_card="${sound_card:-intel-hda}"
sound_duplex="${sound_duplex:-hda-micro}"

ACCESS=""
ACTIONS=()
BRAILLE=""
FULLSCREEN=""
MONITOR_CMD=""
PUBLIC=""
PUBLIC_PERMS=""
PUBLIC_TAG=""
SHORTCUT_OPTIONS=""
SNAPSHOT_ACTION=""
SNAPSHOT_TAG=""
SOCKET_MONITOR=""
SOCKET_SERIAL=""
STATUS_QUO=""
USB_PASSTHROUGH=""
VM=""
VMDIR=""
VMNAME=""
VMPATH=""

# shellcheck disable=SC2155
readonly LAUNCHER=$(basename "${0}")
readonly DISK_MIN_SIZE=$((197632 * 8))
readonly VERSION="4.9.6"

# TODO: Make this run the native architecture binary
ARCH_VM="x86_64"
ARCH_HOST=$(uname -m)
QEMU=$(command -v qemu-system-${ARCH_VM})
QEMU_IMG=$(command -v qemu-img)
if [ ! -x "${QEMU}" ] || [ ! -x "${QEMU_IMG}" ]; then
    echo "ERROR! QEMU not found. Please make sure 'qemu-system-${ARCH_VM}' and 'qemu-img' are installed."
    exit 1
fi

# Check for gnu tools on macOS
STAT="stat"
if command -v gstat &>/dev/null; then
    STAT="gstat"
fi

OS_KERNEL=$(uname -s)
if [ "${OS_KERNEL}" == "Darwin" ]; then
    display="cocoa"
fi

QEMU_VER_LONG=$(${QEMU_IMG} --version | head -n 1 | awk '{print $3}')
QEMU_VER_SHORT=$(echo "${QEMU_VER_LONG//./}" | cut -c1-2)
if [ "${QEMU_VER_SHORT}" -lt 60 ]; then
    echo "ERROR! QEMU 6.0.0 or newer is required, detected ${QEMU_VER_LONG}."
    exit 1
fi

# Take command line arguments
if [ $# -lt 1 ]; then
    usage
    exit 1
else
    while [ $# -gt 0 ]; do
        case "${1}" in
            -access|--access)
                SHORTCUT_OPTIONS+="--access ${2} "
                ACCESS="${2}"
                shift 2;;
            -braille|--braille)
                SHORTCUT_OPTIONS+="--braille "
                BRAILLE="on"
                shift;;
            -delete|--delete|-delete-disk|--delete-disk)
                ACTIONS+=(delete_disk)
                shift;;
            -delete-vm|--delete-vm)
                ACTIONS+=(delete_vm)
                shift;;
            -display|--display)
                SHORTCUT_OPTIONS+="--display ${2} "
                display="${2}"
                display_param_check
                shift 2;;
            -fullscreen|--fullscreen|-full-screen|--full-screen)
                SHORTCUT_OPTIONS+="--fullscreen "
                FULLSCREEN="--full-screen"
                shift;;
            -ignore-msrs-always|--ignore-msrs-always)
                ignore_msrs_always
                exit;;
            -kill|--kill)
                ACTIONS+=(kill_vm)
                shift;;
            -offline|--offline)
                SHORTCUT_OPTIONS+="--offline "
                network="none"
                shift;;
            -snapshot|--snapshot)
                if [ -z "${2}" ]; then
                    echo "ERROR! '--snapshot' needs an action to perform."
                    exit 1
                fi
                SNAPSHOT_ACTION="${2}"
                if [ -z "${3}" ] && [ "${SNAPSHOT_ACTION}" != "info" ]; then
                    echo "ERROR! '--snapshot ${SNAPSHOT_ACTION}' needs a tag."
                    exit 1
                fi
                SNAPSHOT_TAG="${3}"
                if [ "${SNAPSHOT_ACTION}" == "info" ]; then
                    shift 2
                else
                    shift 3
                fi;;
            -status-quo|--status-quo)
                STATUS_QUO="-snapshot"
                shift;;
            -shortcut|--shortcut)
                ACTIONS+=(shortcut_create)
                shift;;
            -vm|--vm)
                VM="${2}"
                shift 2;;
            -viewer|--viewer)
                SHORTCUT_OPTIONS+="--viewer ${2} "
                viewer="${2}"
                shift 2;;
            -width|--width)
                SHORTCUT_OPTIONS+="--width ${2} "
                width="${2}"
                shift 2;;
            -height|--height)
                SHORTCUT_OPTIONS+="--height ${2} "
                height="${2}"
                shift 2;;
            -ssh-port|--ssh-port)
                SHORTCUT_OPTIONS+="--ssh-port ${2} "
                ssh_port="${2}"
                shift 2;;
            -spice-port|--spice-port)
                SHORTCUT_OPTIONS+="--spice-port ${2} "
                spice_port="${2}"
                shift 2;;
            -public-dir|--public-dir)
                SHORTCUT_OPTIONS+="--public-dir ${2} "
                PUBLIC="${2}"
                shift 2;;
            -monitor|--monitor)
                SHORTCUT_OPTIONS+="--monitor ${2} "
                monitor="${2}"
                shift 2;;
            -monitor-cmd|--monitor-cmd)
                SHORTCUT_OPTIONS+="--monitor-cmd ${2} "
                MONITOR_CMD="${2}"
                shift 2;;
            -monitor-telnet-host|--monitor-telnet-host)
                SHORTCUT_OPTIONS+="--monitor-telnet-host ${2} "
                monitor_telnet_host="${2}"
                shift 2;;
            -monitor-telnet-port|--monitor-telnet-port)
                SHORTCUT_OPTIONS+="--monitor-telnet-port ${2} "
                monitor_telnet_port="${2}"
                shift 2;;
            -serial|--serial)
                SHORTCUT_OPTIONS+="--serial ${2} "
                serial="${2}"
                shift 2;;
            -serial-telnet-host|--serial-telnet-host)
                SHORTCUT_OPTIONS+="--serial-telnet-host ${2} "
                serial_telnet_host="${2}"
                shift 2;;
            -serial-telnet-port|--serial-telnet-port)
                SHORTCUT_OPTIONS+="--serial-telnet-port ${2} "
                serial_telnet_port="${2}"
                shift 2;;
            -keyboard|--keyboard)
                SHORTCUT_OPTIONS+="--keyboard ${2} "
                keyboard="${2}"
                shift 2;;
            -keyboard_layout|--keyboard_layout)
                SHORTCUT_OPTIONS+="--keyboard_layout ${2} "
                keyboard_layout="${2}"
                shift 2;;
            -mouse|--mouse)
                SHORTCUT_OPTIONS+="--mouse ${2} "
                mouse="${2}"
                shift 2;;
            -usb-controller|--usb-controller)
                SHORTCUT_OPTIONS+="--usb-controller ${2} "
                usb_controller="${2}"
                shift 2;;
            -extra_args|--extra_args)
                SHORTCUT_OPTIONS+="--extra_args ${2} "
                extra_args+="${2}"
                shift 2;;
            -sound-card|--sound-card)
                SHORTCUT_OPTIONS+="--sound-card ${2} "
                sound_card="${2}"
                shift 2;;
            -sound-duplex|--sound-duplex)
                SHORTCUT_OPTIONS+="--sound-duplex ${2} "
                sound_duplex="${2}"
                shift 2;;
            -version|--version)
                echo "${VERSION}"
                exit;;
            -h|--h|-help|--help)
                usage
                exit 0;;
              *)
                echo "ERROR! \"${1}\" is not a supported parameter."
                usage
                exit 1;;
        esac
    done
fi

if [ -n "${VM}" ] && [ -e "${VM}" ]; then
    # shellcheck source=/dev/null
    source "${VM}"

    VMDIR=$(dirname "${disk_img}")          # directory the VM disk and state files are stored
    VMNAME=$(basename "${VM}" .conf)        # name of the VM
    VMPATH=$(realpath "$(dirname "${VM}")") # path to the top-level VM directory
    SOCKET_MONITOR="${VMDIR}/${VMNAME}-monitor.socket"
    SOCKET_SERIAL="${VMDIR}/${VMNAME}-serial.socket"

    # if disk_img is not configured, do the right thing.
    if [ -z "${disk_img}" ]; then
        disk_img="${VMDIR}/disk.${disk_format}"
    fi

    # Fixes running VMs when PWD is not relative to the VM directory
    # https://github.com/quickemu-project/quickemu/pull/875
    if [ ! -f "${disk_img}" ]; then
        pushd "${VMPATH}" >/dev/null || exit
    fi

    # Check if VM is already running
    VM_PID=""
    if [ -r "${VMDIR}/${VMNAME}.pid" ]; then
        VM_PID=$(head -n 1 "${VMDIR}/${VMNAME}.pid")
        if ! kill -0 "${VM_PID}" > /dev/null 2>&1; then
            #VM is not running, cleaning up.
            VM_PID=""
            rm -f "${VMDIR}/${VMNAME}.pid"
        fi
    fi

    # Iterate over any actions and exit.
    if [ ${#ACTIONS[@]} -ge 1 ]; then
        for ACTION in "${ACTIONS[@]}"; do
            ${ACTION}
        done
        exit
    fi

    if [ -n "${SNAPSHOT_ACTION}" ]; then
        case ${SNAPSHOT_ACTION} in
            apply)
                snapshot_apply "${SNAPSHOT_TAG}"
                snapshot_info
                exit;;
            create)
                snapshot_create "${SNAPSHOT_TAG}"
                snapshot_info
                exit;;
            delete)
                snapshot_delete "${SNAPSHOT_TAG}"
                snapshot_info
                exit;;
            info)
                echo "Snapshot information ${disk_img}"
                snapshot_info
                exit;;
            *)
                echo "ERROR! \"${SNAPSHOT_ACTION}\" is not a supported snapshot action."
                usage
                exit 1;;
        esac
    fi
else
    echo "ERROR! Virtual machine configuration not found."
    usage
    exit 1
fi

display_param_check
ports_param_check
sound_card_param_check
tpm_param_check
viewer_param_check
fileshare_param_check

if [ -z "${VM_PID}" ]; then
    vm_boot
    start_viewer
    # If the VM being started is an uninstalled Windows VM then auto-skip the press-any key prompt.
    if [ -n "${iso}" ] && [[ "${guest_os}" == "windows"* ]]; then
        # shellcheck disable=SC2034
        for LOOP in {1..5}; do
          sleep 1
          monitor_send_cmd "sendkey ret"
        done
    fi
else
    echo "${VMNAME}"
    echo " - Process:  Already running ${VM} as ${VMNAME} (${VM_PID})"
    parse_ports_from_file
    start_viewer
fi

if [ -n "${MONITOR_CMD}" ]; then
    monitor_send_cmd "${MONITOR_CMD}"
fi

# vim:tabstop=4:shiftwidth=4:expandtab

