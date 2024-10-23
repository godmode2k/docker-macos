#!/bin/sh



# macOS in docker
#
# Reference:
#  - https://github.com/sickcodes/Docker-OSX
#  - https://github.com/sickcodes/Docker-OSX/issues/799#issuecomment-2338197880
#  - https://github.com/sickcodes/Docker-OSX/issues/799#issuecomment-2348955503
#
# run:
# $ sudo bash run_docker_macos.sh
#
# hjkim, 2024.10.22



# ------------------------------------------
# Arch
# ------------------------------------------
# sudo pacman -S qemu libvirt dnsmasq virt-manager bridge-utils flex bison iptables-nft edk2-ovmf
#
# ------------------------------------------
# Ubuntu
# ------------------------------------------
# sudo apt-get install qemu qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager libguestfs-tools
#
# ------------------------------------------
# CentOS, RHEL, Fedora
# ------------------------------------------
# sudo yum install libvirt qemu-kvm
#
# ------------------------------------------
# Then, enable libvirt and load the KVM kernel module:
# ------------------------------------------
# sudo systemctl enable --now libvirtd
# sudo systemctl enable --now virtlogd
# echo 1 | sudo tee /sys/module/kvm/parameters/ignore_msrs
# sudo modprobe kvm



# ------------------------------------------
# Registry
# ------------------------------------------
# sickcodes/docker-osx:latest
# seraphix/docker-osx:sonoma



# ------------------------------------------
# enable libvirt and load the KVM kernel module
# ------------------------------------------
#sudo systemctl enable --now libvirtd
#sudo systemctl enable --now virtlogd
#echo 1 | sudo tee /sys/module/kvm/parameters/ignore_msrs
##echo "Y" > /sys/module/kvm/parameters/ignore_msrs
#sudo modprobe kvm
# ------------------------------------------
# disable libvirt and load the KVM kernel module
# ------------------------------------------
#sudo systemctl disable --now libvirtd
#sudo systemctl disable --now virtlogd
#echo 0 | sudo tee /sys/module/kvm/parameters/ignore_msrs
##echo "N" > /sys/module/kvm/parameters/ignore_msrs
#sudo modprobe kvm



echo "# ------------------------------------------"
echo "# You have to"
echo "# enable libvirt and load the KVM kernel module"
echo "# ------------------------------------------"
echo "#"
echo "# Dependencies"
echo "# ------------------------------------------"
echo "# Arch:"
echo "# sudo pacman -S qemu libvirt dnsmasq virt-manager bridge-utils flex bison iptables-nft edk2-ovmf"
echo "# ------------------------------------------"
echo "# Ubuntu:"
echo "# sudo apt-get install qemu qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager libguestfs-tools"
echo "# ------------------------------------------"
echo "# CentOS, RHEL, Fedora:"
echo "# sudo yum install libvirt qemu-kvm"
echo "# ------------------------------------------"
echo "#"
echo "# enable libvirt and load the KVM kernel module:"
echo "# ------------------------------------------"
echo "$ sudo systemctl enable --now libvirtd"
echo "$ sudo systemctl enable --now virtlogd"
echo "$ echo 1 | sudo tee /sys/module/kvm/parameters/ignore_msrs"
echo "$ sudo modprobe kvm"
echo
echo
read -n 1 -r -p "Press any key to continue..." key
echo
echo

echo 1 | sudo tee /sys/module/kvm/parameters/ignore_msrs



# ------------------------------------------
# Sonoma (14)
#
# - images: about 4GiB (images) + 196KiB (qcow2: default init)
# - qcow2 (mac_hdd_ng.img): 30GiB (qcow2: installed)
#
# https://github.com/sickcodes/Docker-OSX/issues/799#issuecomment-2348955503
# NOT WORK, infinite boot loop
# WORK USE with: -e CPU='Haswell-noTSX' -e CPUID_FLAGS='kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on' -e RAM=4 \
#
# https://github.com/sickcodes/Docker-OSX/issues/715
# https://github.com/sickcodes/Docker-OSX/issues/824
# docker run -d -it --name osx-sonoma \
# --device /dev/kvm --device /dev/snd \
# -p 8888:5999 -p 50922:10022 \
# -e CPU='Haswell-noTSX' -e CPUID_FLAGS='kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on' -e RAM=4 \
# --privileged \
# docker-osx:sonoma-vnc
#
# Audio
# - options: {
#   --device /dev/snd \
#   -e AUDIO_DRIVER=pa,server=unix:/tmp/pulseaudio.socket \
#   -v "/run/user/$(id -u)/pulse/native:/tmp/pulseaudio.socket" \
#   or (logged in userid, not 'sudo' for root)
#   -v "/run/user/1000/pulse/native:/tmp/pulseaudio.socket" \
#
# shared directroy
# - macfuse, sshfs not work
# - options: {
#   -v "${SHARE}:/mnt/hostshare" \
#   -e EXTRA="-virtfs local,path=/mnt/hostshare,mount_tag=hostshare,security_model=passthrough,id=hostshare" \
#   then, Open Terminal inside macOS and run the following command to mount the virtual file system
#   sudo -S mount_9p hostshare
#   (macOS) Finder [menu: Go -> Computer] -> you can find 'hostshare'.
# }
# ------------------------------------------
#sudo docker run --rm -it \
#    --device /dev/kvm \
#    -p 50922:10022 \
#    -v /tmp/.X11-unix:/tmp/.X11-unix \
#    -e "DISPLAY=${DISPLAY:-:0.0}" \
#    -e GENERATE_UNIQUE=true \
#    -e MASTER_PLIST_URL='https://raw.githubusercontent.com/sickcodes/osx-serial-generator/master/config-custom.plist' \
#    -e SHORTNAME=sonoma \
#    seraphix/docker-osx:sonoma
#
# working: fixed infinite boot loop, ssh, shared directory
# not: shared clipboard (host <-> guest), audio
SHARE=/path/to/shared_dir
# default init mac_hdd_ng.img (200704 bytes, 196KiB):
# - (container):/home/arch/OSX-KVM/mac_hdd_ng.img
# copy 'initialized mac_hdd_ng.img' file from container:
# - $ sudo docker cp (container):/home/arch/OSX-KVM/mac_hdd_ng.img .
MAC_HDD=./mac_hdd_ng.img
sudo docker run --rm -it \
    --device /dev/kvm \
    -p 50922:10022 \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e "DISPLAY=${DISPLAY:-:0.0}" \
    -e GENERATE_UNIQUE=true \
    -e MASTER_PLIST_URL='https://raw.githubusercontent.com/sickcodes/osx-serial-generator/master/config-custom.plist' \
    -e SHORTNAME=sonoma \
    -e CPU='Haswell-noTSX' -e CPUID_FLAGS='kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on' -e RAM=8 \
    -v "${MAC_HDD}:/home/arch/OSX-KVM/mac_hdd_ng.img" \
    -v "${SHARE}:/mnt/hostshare" \
    -e EXTRA="-virtfs local,path=/mnt/hostshare,mount_tag=hostshare,security_model=passthrough,id=hostshare" \
    seraphix/docker-osx:sonoma



