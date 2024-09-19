#修改网络模式桥接至物理网卡,需要重启
cat <<EOF > /etc/netplan/ens32.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens32:
      dhcp4: no
  bridges:
    br0:
      dhcp4: no
      addresses:
        - 198.19.201.119/24
      routes:
        - to: default
          via: 198.19.201.254
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
      interfaces:
        - ens32
EOF
chmod 600 /etc/netplan/ens32.yaml

if [ ! -e /etc/qemu ];then
mkdir /etc/qemu
fi
echo 'allow br0' > /etc/qemu/bridge.conf
reboot

#创建ARM的EFI BIOS
apt -y install qemu-system-arm
truncate -s 64m efi.img
dd if=/usr/share/qemu-efi-aarch64/QEMU_EFI.fd of=efi.img conv=notrunc


#基于ISO安装OS install.sh
if [ ! -e /data/aarch64 ];then
mkdir /data/aarch64 && cd /data/aarch64
fi
qemu-img create system.img 10G
qemu-system-aarch64 \
-m 4096 \
-cpu cortex-a57 -smp 4 \
-M virt \
-bios efi.img \
-nographic \
-drive if=none,file=alpine-virt-3.20.2-aarch64.iso,id=cdrom,media=cdrom -device virtio-scsi-device -device scsi-cd,drive=cdrom \
-drive if=none,file=system.img,id=hd0 -device virtio-blk-device,drive=hd0 \
-netdev bridge,br=br0,id=net0 -device virtio-net-device,netdev=net0
#run.sh
screen
qemu-system-aarch64 \
-m 2048 \
-cpu cortex-a57 -smp 2 \
-M virt \
-bios efi.img \
-nographic \
-device virtio-scsi-device \
-drive if=none,file=system.img,format=raw,index=0,id=hd0 -device virtio-blk-device,drive=hd0 \
-netdev bridge,br=br0,id=net0 -device virtio-net-device,netdev=net0
