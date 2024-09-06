#下载地址
#https://fw.koolcenter.com/iStoreOS/x86_64_efi/

#解压img
#转换命令
#esxi
qemu-img convert istoreos-22.03.7-2024080210-x86-64-squashfs-combined-efi.img -O vmdk -o subformat=monolithicFlat istoreos-22.03.7-2024080210-x86-64-squashfs-combined-efi.vmdk
#workstation
qemu-img convert istoreos-22.03.7-2024080210-x86-64-squashfs-combined-efi.img -O vmdk  istoreos-22.03.7-2024080210-x86-64-squashfs-combined-efi.vmdk

#新建vmware，1个桥接网卡
#http://ip 默认密码password 系统→管理权→路由器密码
#下载安装passwall插件
#https://github.com/AUK9527/Are-u-ok

