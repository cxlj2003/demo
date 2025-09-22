#!/bin/bash
set -ex

# 一个更通用的镜像列表名称
mirror_list='
100.201.3.111
100.0.0.239
198.18.130.1
'

# 退出状态码，表示失败
readonly EXIT_FAILURE=1

# 来源 /etc/os-release 文件以获取操作系统详细信息
get_os_info() {
    if [[ ! -f /etc/os-release ]]; then
        echo "错误: 无法检测到 Linux 发行版！正在中止。" >&2
        exit "${EXIT_FAILURE}"
    fi
    source /etc/os-release
    echo "检测到操作系统: ${ID}, 版本: ${VERSION_ID}, 代号: ${VERSION_CODENAME:-N/A}"
}

# 检查当前软件源是否可用
check_current_repos() {
    local os_type="${1}"
    echo "正在验证当前软件源..."
    case "${os_type}" in
        InLinux|kylin|uos)
            # 使用 yum clean expire-cache 可以强制过期缓存，然后makecache
            yum clean expire-cache && yum makecache --timer-delay 0 &>/dev/null
            if [ $? -eq 0 ]; then
                echo "当前软件源可用。无需更改。"
                return 0
            else
                echo "当前软件源不可用，将尝试切换。" >&2
                return 1
            fi
            ;;
    esac
}

# 备份现有的仓库文件
backup_repos() {
    local os_type="${1}"
    echo "正在备份现有仓库文件..."
    case "${os_type}" in
        InLinux|kylin|uos)
            find /etc/yum.repos.d/ -type f -name "*.repo" -exec mv -f {} {}.bak \;
            ;;
        *)
            echo "警告: 操作系统类型 '${os_type}' 没有定义备份规则。跳过备份。" >&2
            ;;
    esac
}

# 生成新的仓库文件
generate_repo() {
    local mirror="${1}"
    local os_type="${ID}"
    local os_version_id="${VERSION_ID}"
    local os_codename="${VERSION_CODENAME}"
    local arch="$(uname -i)"
    
    echo "正在为 ${os_type} 在 ${mirror} 上生成新的仓库配置..."

    case "${os_type}" in
        InLinux)
            # 简化 sub_version 逻辑
            local sub_version=""
            if grep -q "SP1" /etc/os-release; then
                sub_version="SP1"
            elif grep -q "SP2" /etc/os-release; then
                sub_version="SP2"
            elif grep -q "SP3" /etc/os-release; then
                sub_version="SP3"
            else
                echo "错误: 不支持的 InLinux 版本。" >&2
                return "${EXIT_FAILURE}"
            fi

            cat << EOF > /etc/yum.repos.d/InLinux_${arch}.repo
###zwc-inlinux_${os_version_id}_${sub_version}_${arch}###
[zwc-inlinux_${os_version_id}_${sub_version}_${arch}-everything]
name = zwc inlinux_${os_version_id}_${sub_version}_${arch} everything
baseurl = http://${mirror}/zwc-inlinux/inlinux_${os_version_id}_${sub_version}_${arch}-everything
enabled = 1
[zwc-inlinux_${os_version_id}_${sub_version}_${arch}-update]
name = zwc inlinux_${os_version_id}_${sub_version}_${arch} update
baseurl = http://${mirror}/zwc-inlinux/inlinux_${os_version_id}_${sub_version}_${arch}-update
enabled = 1

EOF
            ;;
        kylin)
            # 简化 sub_version 逻辑
            local sub_version=""
            if grep -q "Tercel" /etc/os-release; then
                sub_version="SP1"
            elif grep -q "Sword" /etc/os-release; then
                sub_version="SP2"
            elif grep -q "Lance" /etc/os-release; then
                sub_version="SP3"
            else
                echo "错误: 不支持的 Kylin 版本。" >&2
                return "${EXIT_FAILURE}"
            fi

            cat << EOF > /etc/yum.repos.d/kylin_${arch}.repo
##zwc-kylin_${os_version_id}_${sub_version}_${arch}##
[zwc-kylin_${os_version_id}_${sub_version}_${arch}-adv-os]
name = zwc kylin_${os_version_id}_${sub_version}_${arch} adv-os
baseurl = http:///${mirror}/zwc-kylin/kylin_${os_version_id}_${sub_version}_${arch}-adv-os
enabled = 1
[zwc-kylin_${os_version_id}_${sub_version}_${arch}-adv-updates]
name = zwc kylin_${os_version_id}_${sub_version}_${arch} adv-updates
baseurl = http:///${mirror}/zwc-kylin/kylin_${os_version_id}_${sub_version}_${arch}-adv-updates
enabled = 1
EOF
            ;;

        uos)
            if [[ "${os_codename}" == 'fuyu' ]]; then
                cat <<EOF > /etc/yum.repos.d/UnionTechOS-${arch}.repo
[zwc-UnionTechOS-Server-20]
name=UnionTechOS-Server-20-\\${releasever}
baseurl=http://${mirror}/zwc-uos/uos_v20_\${releasever}_${arch}-os
enabled=1
gpgcheck=0

[zwc-UnionTechOS-Server-20-everything]
name=UnionTechOS-Server-20-\\${releasever}-everything
baseurl=http://${mirror}/zwc-uos/uos_v20_\${releasever}_${arch}-everything
enabled=1
gpgcheck=0

[zwc-UnionTechOS-Server-20-update]
name=UnionTechOS-Server-20-\\${releasever}-update
baseurl=http://${mirror}/zwc-uos/uos_v20_\${releasever}_${arch}-update
enabled=1
gpgcheck=0
EOF
            else
                echo "错误: 不支持的 UnionTechOS 版本: ${os_codename}" >&2
                return "${EXIT_FAILURE}"
            fi
            ;;
    esac
}




# 更新软件包缓存
update_cache() {
    local os_type="${1}"
    echo "正在更新软件包缓存..."
    case "${os_type}" in
        InLinux|kylin|openEuler|uos)
            yum clean all && yum makecache || return "${EXIT_FAILURE}"
            ;;
        *)
            echo "警告: 操作系统类型 '${os_type}' 没有定义更新规则。跳过缓存更新。" >&2
            ;;
    esac
}

# --- 主脚本逻辑 ---
get_os_info
# 获取 os-release 文件中的变量，使其在所有函数中可用source /etc/os-release

# 步骤 1: 检查当前软件源是否可用
if check_current_repos "${ID}"; then
    exit 0 # 如果当前源可用，则直接退出
fi

# 步骤 2: 如果当前源不可用，则开始尝试切换
for mirror in ${mirror_list}; do
    echo "--- 正在尝试连接镜像: ${mirror} ---"
    if curl --connect-timeout 5 --silent --head --fail "${mirror}"; then
        echo "成功连接到 ${mirror}。"
        backup_repos "${ID}"
        generate_repo "${mirror}"
        update_cache "${ID}"
        echo "镜像配置已成功更新，使用 ${mirror}。正在退出。"
        exit 0
    else
        echo "连接 ${mirror} 失败。正在尝试列表中的下一个镜像。" >&2
        continue
    fi
done

echo "错误: 列表中没有一个镜像可连接。正在中止。" >&2
exit "${EXIT_FAILURE}"
