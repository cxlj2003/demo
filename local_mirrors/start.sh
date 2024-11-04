#!/bin/bash
set -ex
init_downloader(){
local reponame=$1
local mirrors_root=/opt/mirrors
local repo_root=${mirrors_root}/${reponame}
local repo_list=`yum repolist |grep -E ${reponame}  |awk  '{print $1}' |xargs`

for repo in ${repo_list};do 
  if [ ! -d ${repo_root}/${repo} ];then
    mkdir -p ${repo_root}/${repo}/Packages/
  fi
  reposync --urls --repoid ${repo} > ${repo_root}/${repo}/${repo}.txt
  file=${repo_root}/${repo}/${repo}.txt
  cat $file | while read line;do
    echo $line
    axel -k -c -p -n 4 $line -o ${repo_root}/${repo}/Packages/
  done
done

for repo in ${repo_list};do
   reposync --repoid ${repo} -p ${repo_root}
done 
}

update_downloader(){
local reponame=$1
local mirrors_root=/opt/mirrors
local repo_root=${mirrors_root}/${reponame}
local repo_list=`yum repolist |grep -E ${reponame}  |awk  '{print $1}' |xargs`
for repo in ${repo_list};do
  reposync --repoid ${repo} -np  ${repo_root}/
  createrepo --repo ${repo} --update  ${repo_root}/${repo}
done
}

kylinv10_local_repos(){
local mirrors_root=/opt/mirrors
local repo_root=${mirrors_root}/yum.repos.d
local http_scheme='http://'
local http_port=':80'
yum_server_list='
100.201.3.111
100.0.0.239
192.168.10.239
'
for zwc_yum_server in ${yum_server_list};do
local local_server=${zwc_yum_server}
local repourl=${http_scheme}${local_server}${http_port}/zwc-kylin
local version_arch='
kylin_V10_SP1_aarch64
kylin_V10_SP2_aarch64
kylin_V10_SP3_aarch64
kylin_V10_SP1_x86_64
kylin_V10_SP2_x86_64
kylin_V10_SP3_x86_64
'

#[zwc-${ID}_${VERSION_ID}_${sub_version}_$(uname -i)-adv-os]
#[zwc-${ID}_${VERSION_ID}_${sub_version}_$(uname -i)-adv-updates]
  for v_a in ${version_arch};do
cat << EOF > ${repo_root}/${zwc_yum_server}_${v_a}.repo
##zwc-${v_a}##
[zwc-${v_a}-adv-os]
name = zwc ${v_a} adv-os
baseurl = ${repourl}/${v_a}-adv-os
enabled = 1
[zwc-${v_a}-adv-updates]
name = zwc ${v_a} adv-updates
baseurl = ${repourl}/${v_a}-adv-updates
enabled = 1
EOF
  done
done
}

inlinux_local_repos(){
local mirrors_root=/opt/mirrors
local repo_root=${mirrors_root}/yum.repos.d
local http_scheme='http://'
local http_port=':80'
yum_server_list='
100.201.3.111
100.0.0.239
192.168.10.239
'
for zwc_yum_server in ${yum_server_list};do
local local_server=${zwc_yum_server}
local repourl=${http_scheme}${local_server}${http_port}/zwc-inlinux
local version_arch='
inlinux_23.12_aarch64
inlinux_23.12_x86_64
inlinux_23.12_SP1_aarch64
inlinux_23.12_SP1_x86_64
'

#[zwc-${ID}_${VERSION_ID}_${sub_version}_$(uname -i)-adv-os]
#[zwc-${ID}_${VERSION_ID}_${sub_version}_$(uname -i)-adv-updates]
  for v_a in ${version_arch};do
cat << EOF > ${repo_root}/${zwc_yum_server}_${v_a}.repo
##zwc-${v_a}##
[zwc-${v_a}-everything]
name = zwc ${v_a} everything
baseurl = ${repourl}/${v_a}-everything
enabled = 1
[zwc-${v_a}-update]
name = zwc ${v_a} update
baseurl = ${repourl}/${v_a}-update
enabled = 1
EOF
  done
done
}

set +ex