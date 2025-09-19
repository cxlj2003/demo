#!/bin/bash
set -ex

##创建增量更新脚本
# mkdir -p /data/repo/V10-SP3-x86
# reposync -m -p /data/repo/V10-SP3-x86/
# cd /data/repo/V10-SP3-x86/
# createrepo -g ks10-adv-os/comps.xml .


cat << 'EOF' > /root/update_mirrors.sh
#!/bin/bash
set -ex
update_downloader(){
local reponame=$1
local mirrors_root=/opt/mirrors
local repo_root=${mirrors_root}/${reponame}
local repo_list=$(yum repolist enabled |grep -E ${reponame}  |awk  '{print $1}' |xargs)

for repo in ${repo_list};do 

  ##同步文件
  reposync --repoid ${repo} -np  ${repo_root} --downloadcomps --delete
  local comps_file=${repo_root}/${repo}/comps.xml
  local repond_file=${repo_root}/${repo}/repodata/repomd.xml
  ##生成元数据
  if [[ ! -f ${repond_file} ]];then
    echo "初次生成元数据" 
    if [[ ! -f ${comps_file} ]];then 
      echo "没有找到 ${comps_file} 文件，跳过生成组元数据"
      createrepo_c -p --repo ${repo}  ${repo_root}/${repo} --workers 10
    else
      echo "找到 ${comps_file} 文件，生成组元数据"
      createrepo_c -p --repo ${repo} --groupfile ${comps_file} ${repo_root}/${repo} --workers 10
    fi
  else
    echo "增量更新元数据"    
    if [[ ! -f ${comps_file} ]];then 
      echo "没有找到 ${comps_file} 文件，跳过生成组元数据"
      createrepo_c -p --repo ${repo} --update  ${repo_root}/${repo} --workers 10
    else
      echo "找到 $comps_file} 文件，生成组元数据"
      createrepo_c -p  --repo ${repo} --groupfile ${comps_file} --update  ${repo_root}/${repo} --workers 10
    fi
  fi
done 
}

update_downloader kylin &> /dev/null &
update_downloader inlinux &> /dev/null &
update_downloader UOSV20 &> /dev/null &
set +ex
EOF

##初次运行此脚本

/usr/bin/bash /root/update_mirrors.sh &> /dev/null &


##创建增量更新计划任务
cat << EOF > /var/spool/cron/root
0 0 * * * /usr/bin/bash /root/update_mirrors.sh &> /dev/null
EOF

set +ex
tail -f /dev/null