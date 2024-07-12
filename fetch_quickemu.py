#!/usr/bin/env python3

import requests

get_content = requests.get("https://raw.githubusercontent.com/quickemu-project/quickemu/master/quickget").text

print('quickget downloaded[137557]: %d', len(get_content))

get_fix_quick_emu = 0
get_fix_win_iso = 0
get_fix_ghproxy = 0

with open('quickget.sh', 'wt') as quickget:
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
            download_windows_workstation "${RELEASE}"
        fi
'''.strip('\n')

        if 'https://github.com/kholia/' in line:
            get_fix_ghproxy += 1
            line = line.replace('https://github.com/kholia/', 'https://mirror.ghproxy.com/github.com/kholia/')
        quickget.write(line + '\n')

print('get_fix_win_iso[1]: %d' % get_fix_win_iso)
print('get_fix_ghproxy[3]: %d' % get_fix_ghproxy)

emu_content = requests.get("https://raw.githubusercontent.com/quickemu-project/quickemu/master/quickemu").text


with open('quickemu.sh', 'wt') as quickemu:
    for line in emu_content.split('\n'):
        quickemu.write(line + '\n')

# wget "https://raw.githubusercontent.com/quickemu-project/quickemu/master/quickget" -O quickget.sh
