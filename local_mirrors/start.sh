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
local repo_list=$(yum repolist |grep -E ${reponame}  |awk  '{print $1}' |xargs)

for repo in ${repo_list};do 
  if [ ! -d ${repo_root}/${repo} ];then
    mkdir -p ${repo_root}/${repo}/Packages/
  fi
  if [ ! -d ${repo_root}/${repo}/comps.xml ];then 
   reposync --repoid ${repo} -p ${repo_root} --downloadcomps
   createrepo --groupfile ${repo_root}/${repo}/comps.xml ${repo_root}
  else
    reposync --repoid ${repo} -np  ${repo_root} --downloadcomps
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