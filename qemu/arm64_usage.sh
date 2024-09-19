##qemu-system-aarch64创建和运行VM
apt install qemu-system-arm

truncate -s 64m varstore.img
truncate -s 64m efi.img
dd if=/usr/share/qemu-efi-aarch64/QEMU_EFI.fd of=efi.img conv=notrunc

#在ARM64上运行
qemu-system-aarch64 \
 -enable-kvm \
 -m 1024 \
 -cpu host \
 -M virt \
 -nographic \
 -drive if=pflash,format=raw,file=efi.img,readonly=on \
 -drive if=pflash,format=raw,file=varstore.img \
 -drive if=none,file=jammy-server-cloudimg-arm64.img,id=hd0  -device virtio-blk-device,drive=hd0 \
 -netdev bridge,br=br0,id=net0 -device virtio-net-device,netdev=net0
 

 #在X86上运行
 qemu-system-aarch64 \
 -m 4096 \
 -cpu cortex-a57 -smp 4 \
 -M virt \
 -nographic \
 -drive if=pflash,format=raw,file=efi.img,readonly=on \
 -drive if=pflash,format=raw,file=varstore.img \
 -drive if=none,file=ubuntu-24.04-server-cloudimg-arm64.img,id=hd0 -device virtio-blk-device,drive=hd0 \
 -netdev bridge,br=br0,id=net0 -device virtio-net-device,netdev=net0
#install.sh
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
qemu-system-aarch64 \
-m 2048 \
-cpu cortex-a57 -smp 2 \
-M virt \
-bios efi.img \
-nographic \
-device virtio-scsi-device \
-drive if=none,file=system.img,format=raw,index=0,id=hd0 -device virtio-blk-device,drive=hd0 \
-netdev bridge,br=br0,id=net0 -device virtio-net-device,netdev=net0