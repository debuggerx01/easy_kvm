#!/usr/bin/env bash


VERSION=6
UPDATE_TIME="2025-02-11"

BASE_URL="https://easy-kvm-storage.debuggerx.com/"

# 确保脚本目录和虚拟机镜像目录存在
mkdir -p ~/.local/share/easy_kvm_scripts/
mkdir -p ~/qemu/

QUICK_EMU=~/.local/share/easy_kvm_scripts/quickemu.sh
QUICK_GET=~/.local/share/easy_kvm_scripts/quickget.sh

# 根据当前机器配置计算出合适虚拟机的核心数和内存大小

TOTAL_RAM=$(free --giga | tr ' ' '\n' | grep -m 1 "[0-9]")

if [ "$TOTAL_RAM" -ge "32" ]; then
  RAM=16
elif [  "$TOTAL_RAM" -ge "16"  ]; then
  RAM=$((TOTAL_RAM / 2))
elif [  "$TOTAL_RAM" -ge "12"  ]; then
  RAM=8
elif [  "$TOTAL_RAM" -ge "6"  ]; then
  RAM=$((TOTAL_RAM * 2 / 3))
elif [  "$TOTAL_RAM" -eq "5"  ]; then
  RAM=3
elif [  "$TOTAL_RAM" -eq "4"  ]; then
  RAM=2
elif [  "$TOTAL_RAM" -eq "3"  ]; then
  RAM=2
else
  RAM=1
fi

RAM="$RAM"G

TOTAL_CORES=$(($(grep -c processor < /proc/cpuinfo)))
if [ $TOTAL_CORES -gt "2" ]; then
  CORES=$((TOTAL_CORES * 2 / 3))
else
  CORES=$TOTAL_CORES
fi


# 启动kvm虚拟机时传递的额外参数列表
EXTRA_ARGS=()


# 已存在的虚拟机
VMS=()

# QuickEMU虚拟机安装状态
WIN10=false
WIN11=false
SONOMA=false
VENTURA=false
MONTEREY=false

# 检查更新
function check_update() {
  if [ -e ~/.local/share/easy_kvm_scripts/check_time.txt ]; then
    CHECK_TIME=$(cat ~/.local/share/easy_kvm_scripts/check_time.txt)
    NOW=$(date +%F)
    if ! [ "$CHECK_TIME" == "$NOW" ]; then
      NEW_VERSION=$(curl --max-time 5 "$BASE_URL"version.txt)
      if ! [ "$NEW_VERSION" == $VERSION ]; then
        echo "发现新版本[$VERSION -> $NEW_VERSION]"
        echo "请执行下面的命令更新脚本："
        echo
        echo "curl -sSL https://easy-kvm-storage.debuggerx.com/vm.sh | bash -s -- --install"
        echo
        echo "如果不想现在更新，请再次执行本脚本继续使用"

        echo "$NOW" > ~/.local/share/easy_kvm_scripts/check_time.txt
        exit 0
      fi
    fi
  fi

  echo "$NOW" > ~/.local/share/easy_kvm_scripts/check_time.txt
}

check_update

# 下载文件到指定路径
# params: <文件url> <名称> <目标路径>
function download() {
  echo "开始下载$2[$BASE_URL$1]"
  curl -o /tmp/"$1" "$BASE_URL$1"
  if grep -q "/usr/bin/env bash" /tmp/"$1" || grep -q "Desktop Entry" /tmp/"$1"; then
    echo "$2下载成功"
  else
    echo "$2下载失败"
    echo "请稍后重试"
    exit 1
  fi
  mv /tmp/"$1" "$3"
}

# 安装脚本（更新也是它）
function install_scripts() {

  download vm.sh vm.sh ~/.local/share/easy_kvm_scripts/
  download quickemu.sh quickemu ~/.local/share/easy_kvm_scripts/
  download quickget.sh quickget ~/.local/share/easy_kvm_scripts/
  download easy-kvm.desktop 启动器图标 ~/.local/share/applications/

  chmod a+x ~/.local/share/easy_kvm_scripts/*.sh

  if [ -e ~/.easy_kvm_alias ]; then
    rm ~/.easy_kvm_alias
  fi

  if [ -e ~/.local/share/applications/easy-kvm.desktop ]; then
    sed -i "s%\"~%\"$HOME%g" ~/.local/share/applications/easy-kvm.desktop
  fi

  {
    echo "alias vm='bash ~/.local/share/easy_kvm_scripts/vm.sh'"
    echo "alias vmssh='bash ~/.local/share/easy_kvm_scripts/vm.sh --ssh'"
    echo "alias vmweb='bash ~/.local/share/easy_kvm_scripts/vm.sh --web'"
    echo "alias quickemu='bash ~/.local/share/easy_kvm_scripts/quickemu.sh'"
    echo "alias quickget='bash ~/.local/share/easy_kvm_scripts/quickget.sh'"
  } >> ~/.easy_kvm_alias

  RC_FILE=""

  case $(basename "$SHELL") in
  "bash")
    RC_FILE=~/.bashrc
    ;;
  "zsh")
    RC_FILE=~/.zshrc
    ;;
  esac

  if ! cat $RC_FILE | grep -q '.easy_kvm_alias' ; then
	  cat >> $RC_FILE << EOF


# EasyKVM aliases
if [ -f ~/.easy_kvm_alias ]; then
    . ~/.easy_kvm_alias
fi
EOF
  fi

  echo "安装完成!"
  echo "请执行下面的命令(或重启系统)后，点击启动器图标或执行[vm]命令使用"
  echo "source ~/.easy_kvm_alias"
}

# 获取已安装的虚拟机列表，并检查quickemu虚拟机的安装情况
function get_vm_list() {
  VMS=()
  for VM in ~/qemu/*/disk ; do
    if [ -e "$VM" ]; then
      VMS+=("$(dirname "$VM")")
    fi
  done

  if [ -e ~/qemu/macos-sonoma.conf ] && [ -e ~/qemu/macos-sonoma ]; then
    SONOMA=true
  fi

  if [ -e ~/qemu/macos-ventura.conf ] && [ -e ~/qemu/macos-ventura ]; then
    VENTURA=true
  fi

  if [ -e ~/qemu/macos-monterey.conf ] && [ -e ~/qemu/macos-monterey ]; then
    MONTEREY=true
  fi

  if [ -e ~/qemu/windows-11-Chinese-Simplified.conf ] && [ -e ~/qemu/windows-11-Chinese-Simplified/disk.qcow2 ]; then
    WIN11=true
  fi

  if [ -e ~/qemu/windows-10-Chinese-Simplified.conf ] && [ -e ~/qemu/windows-10-Chinese-Simplified/disk.qcow2 ]; then
    WIN10=true
  fi
}


# 检查安装所需组件
function check_kvm_and_tools() {
  if ! [ -e /usr/bin/kvm ]; then
    echo "安装KVM"
    sudo apt install -y qemu-system-x86
  fi

  if ! [ -e /usr/bin/dialog ]; then
    echo "安装dialog"
    sudo apt install -y dialog
  fi

  if ! [ -e /usr/bin/zenity ]; then
    echo "安装zenity"
    sudo apt install -y zenity
  fi

  if ! [ -e /usr/bin/zstd ]; then
    echo "安装zstd"
    sudo apt install -y zstd
  fi

  # 以下是quickemu 依赖
  if ! [ -e /usr/bin/genisoimage ]; then
    echo "安装genisoimage"
    sudo apt install -y genisoimage
  fi

  if ! [ -e /usr/bin/jq ]; then
    echo "安装jq"
    sudo apt install -y jq
  fi

  if ! [ -e /usr/bin/jq ]; then
    echo "安装jq"
    sudo apt install -y jq
  fi

  if ! [ -e /usr/bin/glxinfo ]; then
    echo "安装mesa-utils"
    sudo apt install -y mesa-utils
  fi

  if ! [ -e /usr/share/ovmf ]; then
    echo "安装ovmf"
    sudo apt install -y ovmf
  fi

  if ! [ -e /usr/bin/lspci ]; then
    echo "安装pciutils"
    sudo apt install -y pciutils
  fi

  if ! [ -e /usr/bin/socat ]; then
    echo "安装socat"
    sudo apt install -y socat
  fi

  if ! [ -e /usr/bin/spicy ]; then
    echo "安装spice-client-gtk"
    sudo apt install -y spice-client-gtk
  fi

  if ! [ -e /usr/bin/swtpm_setup ]; then
    echo "安装swtpm-tools"
    sudo apt install -y swtpm-tools
  fi

  if ! [ -e /usr/bin/unzip ]; then
    echo "安装unzip"
    sudo apt install -y unzip
  fi

  if ! [ -e /usr/bin/lsusb ]; then
    echo "安装usbutils"
    sudo apt install -y usbutils
  fi

  if ! [ -e /usr/bin/uuidgen ]; then
    echo "安装uuidgen"
    sudo apt install -y uuid-runtime
  fi

  if ! [ -e /usr/bin/uuidgen ]; then
    echo "安装uuidgen"
    sudo apt install -y uuid-runtime
  fi
}

# 创建虚拟机
function create_vm() {
  if [ "$1" == "" ]; then
    echo "请输入虚拟机名称" >&2
  elif [ -e ~/qemu/"$1" ]; then
    echo "虚拟机已存在，请输入其他名称" >&2
  elif ! [[ $1 =~ ^[0-9a-zA-Z._-]+$ ]]; then
    echo '不允许的名称，请仅使用数字、字母、[-]、[_]和[.]命名虚拟机' >&2
  elif ! [[ $2 =~ ^[1-9][0-9]?+$ ]]; then
    echo "请输入正确的虚拟机容量（大于0的整数）" >&2
  else
    mkdir -p ~/qemu/"$1"
    qemu-img create -f raw ~/qemu/"$1"/disk "$2"G
    return 0
  fi

  return 1
}

# 等待QuickEMU退出
function start_quick_emu_and_await_exit() {
  if [ -e /sys/module/kvm/parameters/ignore_msrs ]; then
    ignore_msrs=$(cat /sys/module/kvm/parameters/ignore_msrs)
    if [ "${ignore_msrs}" == "N" ]; then
        echo "如果虚拟机启动异常，可以尝试执行下面的命令后再启动"
        echo
        echo "echo 1 | sudo tee /sys/module/kvm/parameters/ignore_msrs"
        echo
        echo "如果修复有效，并希望以后启动虚拟机时无需重复执行该命令，可以运行下面的命令使其永久生效"
        echo
        echo "quickemu --ignore-msrs-always"
    fi
  fi


  cd ~/qemu/ || exit 1
  bash $QUICK_EMU --vm "$1".conf
  sleep 3
  while true; do
    if ! [ -e ~/qemu/"$1"/"$1".pid ]; then
      exit 0
    fi
    sleep 1
  done
}

# 下载或删除QuickEMU虚拟机
function get_or_delete_quick_vm() {
  clear
  cd ~/qemu/ || exit 1
  if [ -e ~/qemu/"$1".conf ] && [ -e ~/qemu/"$1"/disk.qcow2 ]; then
    rm -rf ~/qemu/"$1"
    rm ~/qemu/"$1".conf
    echo "删除成功!"
  else
    case $1 in
    "macos-sonoma")
      bash $QUICK_GET macos sonoma
      ;;
    "macos-ventura")
      bash $QUICK_GET macos ventura
      ;;
    "macos-monterey")
      bash $QUICK_GET macos monterey
      ;;
    "windows-11-Chinese-Simplified")
      bash $QUICK_GET windows 11 "Chinese (Simplified)"
      ;;
    "windows-10-Chinese-Simplified")
      bash $QUICK_GET windows 10 "Chinese (Simplified)"
      ;;
    esac
    start_quick_emu_and_await_exit "$1"
    read -rn 1 -p "按任意键退出"
  fi
}

# 显示主菜单
function show_menu() {
  OPTS=()
  for VM in "${VMS[@]}"; do
    ((INDEX++)) || true
    DISK_INFO=$(qemu-img info "$VM"/disk | awk '{print $3$4}' | xargs)
    TOTAL=$(echo "$DISK_INFO" | awk '{print $2}')
    USED=$(echo "$DISK_INFO" | awk '{print $3}')

    OPTS+=("$(basename "$VM")" "已占用/最大容量: $USED/$TOTAL")
  done

  if [ $WIN10 == true ]; then
    OPTS+=("Windows 10" "QuickEMU创建的Windows虚拟机")
  fi

  if [ $WIN11 == true ]; then
    OPTS+=("Windows 11" "QuickEMU创建的Windows虚拟机")
  fi

  if [ $SONOMA == true ]; then
    OPTS+=("MacOS Sonoma" "QuickEMU创建的MacOS虚拟机")
  fi

  if [ $VENTURA == true ]; then
    OPTS+=("MacOS Ventura" "QuickEMU创建的MacOS虚拟机")
  fi

  if [ $MONTEREY == true ]; then
    OPTS+=("MacOS Monterey" "QuickEMU创建的MacOS虚拟机")
  fi

  OPTS+=("-----------------" "-----------------")
  OPTS+=("新建虚拟机" "创建虚拟机镜像，并使用iso镜像创建虚拟机")
  OPTS+=("试用iso" "不创建虚拟机，仅选择iso镜像用于进入LiveCD模式")
  OPTS+=("管理虚拟机" "可以备份、压缩、删除虚拟机镜像")
  OPTS+=("-----------------" "-----------------")
  OPTS+=("QuickEMU" "使用QuickEMU创建或删除Win/Mac虚拟机")

  selection=$(dialog --stdout \
    --backtitle "KVM Tools" \
    --clear \
    --clear \
    --menu "请选择要启动的虚拟机或操作选项:" 0 72 0 \
    "${OPTS[@]}"
  )

  clear

  case $selection in
  "")
    exit 0
    ;;
  新建虚拟机)
    args=$(dialog --stdout --clear --title "新建虚拟机" --form "↑↓键切换输入框、Tab键切换[确认]\[取消]按钮、回车确认输入\n注意：1. 虚拟机名称一定不能包含空格！\n      2. 请仅使用数字、字母、[-]、[_]和[.]命名虚拟机\n      3. 硬盘容量请输入大于0的整数，单位是GB" 0 0 0 \
    "虚拟机名称:" 1 1 "" 1 20 36 0 \
    "虚拟硬盘容量(G):"  3 1 "" 3 20 36 0 | xargs)
    clear

    # shellcheck disable=SC2086
    create_vm $args || exit 1

    IFS=' ' read -ra args <<< "$args"

    ISO=$(zenity --file-selection --file-filter=*.iso)

    if ! [ "$ISO" == "" ]; then
      kvm -m $RAM -cpu host -smp $CORES -drive format=raw,file="$HOME"/qemu/"${args[0]}"/disk -cdrom "$ISO" "${EXTRA_ARGS[@]}"
    fi
    ;;
  试用iso)
    ISO=$(zenity --file-selection --file-filter=*.iso)
    if ! [ "$ISO" == "" ]; then
      kvm -m $RAM -cpu host -smp $CORES -cdrom "$ISO" "${EXTRA_ARGS[@]}"
    fi
    ;;
  管理虚拟机)
    OPTS=()
    for VM in "${VMS[@]}"; do
      ((INDEX++)) || true
      DISK_INFO=$(qemu-img info "$VM"/disk | awk '{print $3$4}' | xargs)
      TOTAL=$(echo "$DISK_INFO" | awk '{print $2}')
      USED=$(echo "$DISK_INFO" | awk '{print $3}')

      if [ -e "$VM"/disk.zst ]; then
        BACKUP='已备份'
      else
        BACKUP='未备份'
      fi

      OPTS+=("$(basename "$VM")" "$BACKUP 已占用/最大容量: $USED/$TOTAL")
    done

    selection1=$(dialog --stdout \
      --backtitle "KVM Tools" \
      --clear \
      --menu "请选择要操作的虚拟机:" 0 0 0 \
      "${OPTS[@]}"
    )

    clear

    if [ "$selection1" == "" ]; then
      exit 0
    fi

    selection2=$(dialog --stdout \
      --backtitle "KVM Tools" \
      --clear \
      --menu "请选择要执行的操作" 0 0 0 \
      1 "备份虚拟机镜像" \
      2 "还原虚拟机镜像" \
      3 "压缩虚拟机镜像" \
      4 "删除虚拟机"
    )

    if [ "$selection2" == "" ]; then
      exit 0
    fi

    clear

    cd ~/qemu/"$selection1"/ || exit 1

    case $selection2 in
    1)
      echo "开始备份虚拟机镜像"
      zstd -1 disk -o disk.zst
      echo "备份完成！"
      ;;
    2)
      if [ -e ~/qemu/"$selection1"/disk.zst ]; then
        echo "开始还原虚拟机镜像"
        zstd -d -f disk.zst -o disk
        echo "还原完成！"
      else
        echo "未找到虚拟机镜像备份文件！"
      fi
      ;;
    3)
      echo "开始压缩虚拟机镜像"
      qemu-img convert -f raw -O raw disk disk_shink -p
      mv disk_shink disk
      echo "压缩完成！"
      ;;
    4)
      rm -rf ~/qemu/"$selection1"
      echo "删除成功！"
      ;;
    esac

    ;;
  QuickEMU)
    OPTS=()
    if [ $SONOMA == true ]; then
      OPTS+=("MacOS Sonoma" "删除MacOS Sonoma")
    else
      OPTS+=("MacOS Sonoma" "安装MacOS Sonoma")
    fi

    if [ $VENTURA == true ]; then
      OPTS+=("MacOS Ventura" "删除MacOS Ventura")
    else
      OPTS+=("MacOS Ventura" "安装MacOS Ventura")
    fi

    if [ $MONTEREY == true ]; then
      OPTS+=("MacOS Monterey" "删除MacOS Monterey")
    else
      OPTS+=("MacOS Monterey" "安装MacOS Monterey")
    fi

    if [ $WIN11 == true ]; then
      OPTS+=("Windows 11" "删除Windows 11")
    else
      OPTS+=("Windows 11" "自动下载安装Windows 11")
      OPTS+=("Windows 11(iso)" "使用iso镜像安装Windows 11")
    fi

    if [ $WIN10 == true ]; then
      OPTS+=("Windows 10" "删除Windows 10")
    else
      OPTS+=("Windows 10" "自动下载安装Windows 10")
      OPTS+=("Windows 10(iso)" "使用iso镜像安装Windows 10")
    fi

    selection=$(dialog --stdout \
      --clear \
      --menu "请选择要执行的操作:" 0 0 0 \
      "${OPTS[@]}"
    )

    clear

    case $selection in
    "MacOS Sonoma")
      get_or_delete_quick_vm macos-sonoma
      ;;
    "MacOS Ventura")
      get_or_delete_quick_vm macos-ventura
      ;;
    "MacOS Monterey")
      get_or_delete_quick_vm macos-monterey
      ;;
    "Windows 11")
      get_or_delete_quick_vm windows-11-Chinese-Simplified
      ;;
    "Windows 11(iso)")
      ISO=$(zenity --file-selection --file-filter=*.iso)
      if [ "$ISO" == "" ]; then
        echo "请选择原版Windows 11 iso镜像"
        exit 0
      else
        mkdir -p ~/qemu/windows-11-Chinese-Simplified/
        echo 正在复制iso镜像文件
        cp "$ISO" ~/qemu/windows-11-Chinese-Simplified/windows-11.iso
      fi
      get_or_delete_quick_vm windows-11-Chinese-Simplified
      ;;
    "Windows 10")
      get_or_delete_quick_vm windows-10-Chinese-Simplified
      ;;
    "Windows 10(iso)")
      ISO=$(zenity --file-selection --file-filter=*.iso)
      if [ "$ISO" == "" ]; then
        echo "请选择原版Windows 10 iso镜像"
        exit 0
      else
        mkdir -p ~/qemu/windows-10-Chinese-Simplified/
        echo 正在复制iso镜像文件
        cp "$ISO" ~/qemu/windows-10-Chinese-Simplified/windows-10.iso
      fi
      get_or_delete_quick_vm windows-10-Chinese-Simplified
      ;;
    esac


    ;;
  "-----------------")
    echo '我只是个没有感情的分割线而已～'
    ;;
  "MacOS Sonoma")
    start_quick_emu_and_await_exit macos-sonoma
    ;;
  "MacOS Ventura")
    start_quick_emu_and_await_exit macos-ventura
    ;;
  "MacOS Monterey")
    start_quick_emu_and_await_exit macos-monterey
    ;;
  "Windows 11")
    start_quick_emu_and_await_exit windows-11-Chinese-Simplified
    ;;
  "Windows 10")
    start_quick_emu_and_await_exit windows-10-Chinese-Simplified
    ;;
  *)
    kvm -m $RAM -cpu host -smp $CORES -drive format=raw,file="$HOME"/qemu/"$selection"/disk "${EXTRA_ARGS[@]}"
  esac

  clear
}

# 正式进入脚本流程，先检查并安装所需组件
check_kvm_and_tools

if [ -f ~/.local/share/easy_kvm_scripts/default_args.txt ]; then
  # 设置IFS为空格，以便read命令可以正确地按空格分割字符串
  IFS=' '
  read -ra EXTRA_ARGS <<< "$(cat ~/.local/share/easy_kvm_scripts/default_args.txt)"
fi

if ! [ "$#" == "0" ]; then
  case $1 in
  "--ssh")
    EXTRA_ARGS=("${EXTRA_ARGS[@]}" "-nic" "user,hostfwd=tcp::8022-:22")
    shift
    EXTRA_ARGS=("${EXTRA_ARGS[@]}" "$@")
    echo "${EXTRA_ARGS[@]}"
    exit 0
    ;;
  "--web")
    EXTRA_ARGS=("${EXTRA_ARGS[@]}" "-nic" "user,hostfwd=tcp::8080-:8080")
    shift
    EXTRA_ARGS=("${EXTRA_ARGS[@]}" "$@")
    ;;
  "--version")
    echo "版本[$VERSION] 更新日期[$UPDATE_TIME]"
    exit 0
    ;;
  "--install")
    install_scripts
    exit 0
    ;;
  "--params")
    if [ -e ~/.local/share/easy_kvm_scripts/default_args.txt ]; then
      cat ~/.local/share/easy_kvm_scripts/default_args.txt
    else
      echo '未设置默认参数'
      echo '请使用 [vm --set-params] 命令设置'
      echo '例如: vm --set-params -nic user,hostfwd=tcp::8080-:8080 -vga virtio'
    fi
    exit 0
    ;;
  "--set-params")
    shift
    echo "$@" > ~/.local/share/easy_kvm_scripts/default_args.txt
    exit 0
    ;;
  *)
    EXTRA_ARGS=("${EXTRA_ARGS[@]}" "$@")
    ;;
  esac
fi

if [ -e disk ]; then
  # 如果脚本执行的目录下有disk镜像文件，不显示选择框直接调用kvm命令启动虚拟机
  kvm -m $RAM -cpu host -smp $CORES -drive format=raw,file=disk "${EXTRA_ARGS[@]}"
else
  get_vm_list
  show_menu
fi
