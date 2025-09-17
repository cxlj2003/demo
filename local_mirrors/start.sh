#!/bin/bash
set -ex

##创建增量更新脚本

cat << 'EOF' > /root/update_mirrors.sh
#!/bin/bash
set -ex
update_downloader(){
local reponame=$1
local mirrors_root=/opt/mirrors
local repo_root=${mirrors_root}/${reponame}
local repo_list=$(yum repolist enabled |grep -E ${reponame}  |awk  '{print $1}' |xargs)

for repo in ${repo_list};do 
  if [[ ! -d ${repo_root}/${repo} ]];then
    mkdir -p ${repo_root}/${repo}/Packages/
  fi
  ##同步文件
  reposync --repoid ${repo} -np  ${repo_root} --downloadcomps --delete
  ##生成元数据
  if [[ ! -f ${repo_root}/${repo}/repodata/repomd.xml ]];then
    echo "初次生成元数据" 
    if [[ ! -f ${repo_root}/${repo}/comps.xml ]];then 
      echo "没有找到 ${repo_root}/${repo}/comps.xml 文件，跳过生成组元数据"
      createrepo --repo ${repo}  ${repo_root}
    else
      echo "找到 ${repo_root}/${repo}/comps.xml 文件，生成组元数据"
      createrepo --repo ${repo} --groupfile ${repo_root}/${repo}/comps.xml ${repo_root}
    fi
  else
    echo "增量更新元数据"
    createrepo --repo ${repo} --update  ${repo_root}/${repo}
  fi
done 
}
update_downloader kylin &> /dev/null &
update_downloader inlinux &> /dev/null &
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