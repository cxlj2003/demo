#!/bin/bash
set -ex

# һ����ͨ�õľ����б�����
mirror_list='
100.201.3.111
100.0.0.239
198.18.130.1
'

# �˳�״̬�룬��ʾʧ��
readonly EXIT_FAILURE=1

# ��Դ /etc/os-release �ļ��Ի�ȡ����ϵͳ��ϸ��Ϣ
get_os_info() {
    if [[ ! -f /etc/os-release ]]; then
        echo "����: �޷���⵽ Linux ���а棡������ֹ��" >&2
        exit "${EXIT_FAILURE}"
    fi
    source /etc/os-release
    echo "��⵽����ϵͳ: ${ID}, �汾: ${VERSION_ID}, ����: ${VERSION_CODENAME:-N/A}"
}

# ��鵱ǰ���Դ�Ƿ����
check_current_repos() {
    local os_type="${1}"
    echo "������֤��ǰ���Դ..."
    case "${os_type}" in
        InLinux|kylin|uos)
            # ʹ�� yum clean expire-cache ����ǿ�ƹ��ڻ��棬Ȼ��makecache
            yum clean expire-cache && yum makecache --timer-delay 0 &>/dev/null
            if [ $? -eq 0 ]; then
                echo "��ǰ���Դ���á�������ġ�"
                return 0
            else
                echo "��ǰ���Դ�����ã��������л���" >&2
                return 1
            fi
            ;;
    esac
}

# �������еĲֿ��ļ�
backup_repos() {
    local os_type="${1}"
    echo "���ڱ������вֿ��ļ�..."
    case "${os_type}" in
        InLinux|kylin|uos)
            find /etc/yum.repos.d/ -type f -name "*.repo" -exec mv -f {} {}.bak \;
            ;;
        *)
            echo "����: ����ϵͳ���� '${os_type}' û�ж��屸�ݹ����������ݡ�" >&2
            ;;
    esac
}

# �����µĲֿ��ļ�
generate_repo() {
    local mirror="${1}"
    local os_type="${ID}"
    local os_version_id="${VERSION_ID}"
    local os_codename="${VERSION_CODENAME}"
    local arch="$(uname -i)"
    
    echo "����Ϊ ${os_type} �� ${mirror} �������µĲֿ�����..."

    case "${os_type}" in
        InLinux)
            # �� sub_version �߼�
            local sub_version=""
            if grep -q "SP1" /etc/os-release; then
                sub_version="SP1"
            elif grep -q "SP2" /etc/os-release; then
                sub_version="SP2"
            elif grep -q "SP3" /etc/os-release; then
                sub_version="SP3"
            else
                echo "����: ��֧�ֵ� InLinux �汾��" >&2
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
            # �� sub_version �߼�
            local sub_version=""
            if grep -q "Tercel" /etc/os-release; then
                sub_version="SP1"
            elif grep -q "Sword" /etc/os-release; then
                sub_version="SP2"
            elif grep -q "Lance" /etc/os-release; then
                sub_version="SP3"
            else
                echo "����: ��֧�ֵ� Kylin �汾��" >&2
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
                echo "����: ��֧�ֵ� UnionTechOS �汾: ${os_codename}" >&2
                return "${EXIT_FAILURE}"
            fi
            ;;
    esac
}




# �������������
update_cache() {
    local os_type="${1}"
    echo "���ڸ������������..."
    case "${os_type}" in
        InLinux|kylin|openEuler|uos)
            yum clean all && yum makecache || return "${EXIT_FAILURE}"
            ;;
        *)
            echo "����: ����ϵͳ���� '${os_type}' û�ж�����¹�������������¡�" >&2
            ;;
    esac
}

# --- ���ű��߼� ---
get_os_info
# ��ȡ os-release �ļ��еı�����ʹ�������к����п���source /etc/os-release

# ���� 1: ��鵱ǰ���Դ�Ƿ����
if check_current_repos "${ID}"; then
    exit 0 # �����ǰԴ���ã���ֱ���˳�
fi

# ���� 2: �����ǰԴ�����ã���ʼ�����л�
for mirror in ${mirror_list}; do
    echo "--- ���ڳ������Ӿ���: ${mirror} ---"
    if curl --connect-timeout 5 --silent --head --fail "${mirror}"; then
        echo "�ɹ����ӵ� ${mirror}��"
        backup_repos "${ID}"
        generate_repo "${mirror}"
        update_cache "${ID}"
        echo "���������ѳɹ����£�ʹ�� ${mirror}�������˳���"
        exit 0
    else
        echo "���� ${mirror} ʧ�ܡ����ڳ����б��е���һ������" >&2
        continue
    fi
done

echo "����: �б���û��һ����������ӡ�������ֹ��" >&2
exit "${EXIT_FAILURE}"
