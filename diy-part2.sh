#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

rm -rf luci/applications/luci-app-argon-config
rm -rf feeds/applications/luci-theme-argon
rm -rf luci/applications/luci-theme-argon
rm -rf feeds/applications/luci-app-argon-config
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git luci-app-argon-config
rm -rf feeds/luci/applications/luci-app-gowebdav
rm -rf feeds/packages/net/gowebdav
git clone --depth=1 https://github.com/tty228/luci-app-serverchan.git package/luci-app-serverchan
rm -rf feeds/luci/applications/luci-app-netdata
git clone --depth=1 https://github.com/sirpdboy/luci-app-netdata package/luci-app-netdata
ln -s package/luci-app-netdata/po/zh-cn package/luci-app-netdata/po/zh_Hans

#svn co https://github.com/sbwml/openwrt_pkgs/trunk/luci-app-gowebdav package/luci-app-gowebdav
#svn co https://github.com/sbwml/openwrt_pkgs/trunk/gowebdav package/gowebdav
# git clone https://github.com/vernesong/OpenClash.git -b master --single-branch luci-app-openclash
function merge_package() {
        # 参数1是分支名,参数2是库地址,参数3是所有文件下载到指定路径。
        # 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
        if [[ $# -lt 3 ]]; then
        echo "Syntax error: [$#] [$*]" >&2
        return 1
        fi
        trap 'rm -rf "$tmpdir"' EXIT
        branch="$1" curl="$2" target_dir="$3" && shift 3
        rootdir="$PWD"
        localdir="$target_dir"
        [ -d "$localdir" ] || mkdir -p "$localdir"
        tmpdir="$(mktemp -d)" || exit 1
        git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"
        cd "$tmpdir"
        git sparse-checkout init --cone
        git sparse-checkout set "$@"
        # 使用循环逐个移动文件夹
        for folder in "$@"; do
        mv -f "$folder" "$rootdir/$localdir"
        done
        cd "$rootdir"
        }
#        merge_package master https://github.com/sbwml/openwrt_pkgs package/openwrt-packages gowebdav luci-app-gowebdav 
        merge_package master https://github.com/messense/aliyundrive-webdav package/openwrt-packages aliyundrive-webdav luci-app-aliyundrive-webdav 

git clone --depth=1 https://github.com/vernesong/OpenClash.git
cp -rf OpenClash/luci-app-openclash package/luci-app-openclash
# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/luci-app-openclash/tools/po2lmo
make && sudo make install
popd   

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# samba解除root限制
sed -i 's/invalid users = root/#&/g' feeds/packages/net/samba4/files/smb.conf.template

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate
