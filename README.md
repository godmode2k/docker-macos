# Docker-macOS


Summary
----------
> Run macOS in Docker </br>
>
> source-based: https://github.com/sickcodes/Docker-OSX </br>
> USE THIS AT YOUR OWN RISK.


Environment
----------
> build all and tested on GNU/Linux

    GNU/Linux: Ubuntu 20.04_x64 LTS


Run
----------
```sh
// Docker installation
https://docs.docker.com/engine/install/


// Arch
$ sudo pacman -S qemu libvirt dnsmasq virt-manager bridge-utils flex bison iptables-nft edk2-ovmf


// Ubuntu
$ sudo apt-get install qemu qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager libguestfs-tools


// CentOS, RHEL, Fedora
$ sudo yum install libvirt qemu-kvm


// Then, enable libvirt and load the KVM kernel module
$ sudo systemctl enable --now libvirtd
$ sudo systemctl enable --now virtlogd
$ echo 1 | sudo tee /sys/module/kvm/parameters/ignore_msrs
$ sudo modprobe kvm



// macOS Sonoma (14)
$ sudo bash run_docker_macos.sh



---------------------------------
Errors:
---------------------------------
1. infinite boot loop
 - options: {
    -e CPU='Haswell-noTSX' -e CPUID_FLAGS='kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on' -e RAM=4
   }

2. shared directroy: macfuse, sshfs does not work (macOS in docker (QEMU))
 - options: {
    -v "${SHARE}:/mnt/hostshare" \
    -e EXTRA="-virtfs local,path=/mnt/hostshare,mount_tag=hostshare,security_model=passthrough,id=hostshare"
   }

   then, Open Terminal inside macOS and run the following command to mount the virtual file system

   $ sudo -S mount_9p hostshare
   (macOS) Finder [menu: Go -> Computer] -> you can find 'hostshare'.

```



