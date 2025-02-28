#!/usr/bin/env python3

import requests
import re
import os

virtio_win_iso = 'https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso'

def fix_cf(line, link, skip_download=False):
    file_name = link.split(r'/')[-1]
    if not skip_download:
        print('start download: ', file_name)
        with open(os.path.join('./upload', file_name), 'wb') as save_file:
            save_file.write(requests.get(link).content)
    return line.replace(link, 'https://easy-kvm-storage.debuggerx.com/%s' % file_name)

get_content = requests.get("https://raw.githubusercontent.com/quickemu-project/quickemu/master/quickget").text

print('quickget downloaded[139958]: ', len(get_content))

get_fix_quick_emu = 0
get_fix_win_iso = 0
get_fix_cf_mac = 0
get_fix_cf_win = 0
get_curl_retry = 0

if not os.path.exists('./upload'):
    os.mkdir('./upload')

with open(os.path.join('./upload', 'quickget.sh'), 'wt') as quickget:
    for line in get_content.split('\n'):
        if 'QUICKEMU=$(resolve_quickemu)' in line:
            get_fix_quick_emu += 1
            line = 'QUICKEMU=quickemu'
        if 'download_windows_workstation ' in line:
            get_fix_win_iso += 1
            line = '''
        if [ -e ~/qemu/windows-"${RELEASE}"-Chinese-Simplified/windows-"${RELEASE}".iso ]; then
            echo "使用自定义iso安装"
        else
            if [ "${RELEASE}" == "11" ]; then
                echo "开始下载 [zh-cn_windows_11_consumer_editions_version_23h2_updated_nov_2024_x64_dvd_212bfc41.iso] :"
                web_get "https://easy-kvm-storage.debuggerx.com/zh-cn_windows_11_consumer_editions_version_23h2_updated_nov_2024_x64_dvd_212bfc41.iso" "${VM_PATH}" "windows-11.iso"
            else
                download_windows_workstation "${RELEASE}"
            fi
        fi
'''.strip('\n')

        if 'https://github.com/kholia/' in line:
            get_fix_cf_mac += 1
            link = re.compile(r'".+?"').findall(line)[0][1: -1]
            line = fix_cf(line, link)

        if virtio_win_iso in line:
            get_fix_cf_win += 1
            line = fix_cf(line, virtio_win_iso, skip_download=get_fix_cf_win==1)

        if 'curl --progress-bar' in line:
            get_curl_retry += 1
            line = line.replace('curl', 'curl --retry 3 --retry-delay 5')

        quickget.write(line + '\n')

print('get_fix_quick_emu[1]: %d' % get_fix_quick_emu)
print('get_fix_win_iso[1]: %d' % get_fix_win_iso)
print('get_fix_cf_mac[3]: %d' % get_fix_cf_mac)
print('get_fix_cf_win[2]: %d' % get_fix_cf_win)
print('get_curl_retry[1]: %d' % get_curl_retry)

with open(os.path.join('./upload', 'quickemu.sh'), 'wt') as quickemu:
    quickemu.write(requests.get("https://raw.githubusercontent.com/quickemu-project/quickemu/master/quickemu").text)

os.system('cp easy-kvm.desktop ./upload/')
os.system('cp version.txt ./upload/')
os.system('cp vm.sh ./upload/')
