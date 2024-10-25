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
Issues
---------------------------------
1. infinite boot loop
 - USE this options: {
    -e CPU='Haswell-noTSX' -e CPUID_FLAGS='kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on' -e RAM=4
   }


2. shared directroy: macfuse, sshfs does not work (macOS in docker (QEMU))
 - USE this options: {
    -v "${SHARE}:/mnt/hostshare" \
    -e EXTRA="-virtfs local,path=/mnt/hostshare,mount_tag=hostshare,security_model=passthrough,id=hostshare"
   }

   then, Open Terminal inside macOS and run the following command to mount the virtual file system

   (macOS)$ sudo -S mount_9p hostshare
   (macOS) Finder [menu: Go -> Computer] -> you can find 'hostshare'.


3. Audio
 - USE this options: {
   --device /dev/snd \
    -e AUDIO_DRIVER=pa,server=unix:/tmp/pulseaudio.socket \

    -v "/run/user/$(id -u)/pulse/native:/tmp/pulseaudio.socket" \
    or (logged in userid, not 'sudo' for root)
    -v "/run/user/1000/pulse/native:/tmp/pulseaudio.socket" \

    -e EXTRA="-virtfs local,path=/mnt/hostshare,mount_tag=hostshare,security_model=passthrough,id=hostshare -device intel-hda -device hda-output,audiodev=hda" \
    -e NOPICKER=false \
   }

   then,
   source-based:
    - https://github.com/MobCode100/Dastux/blob/main/VoodooHDA-QEMU-KVM.md
    - https://sourceforge.net/projects/voodoohda (download: latest version, VoodooHDA.kext-v301.zip)

   Disable System Integrity Protection (SIP)
   (macOS) boot menu > select Recovery partition: Go to Utilities > Terminal
   (macOS)$ csrutil status    // you can skip below command if result like this 'System Integrity Protection status: disabled' or 'Kext Signing: disabled'
   (macOS)$ csrutil disable
   or
   (macOS)$ csrutil enable --without kext
   (macOS) reboot macOS

   https://sourceforge.net/projects/voodoohda: download VoodooHDA, VoodooHDA.kext-v301.zip (latest version)
   (macOS)$ sudo cp -R Downloads/VoodooHDA.kext /Library/Extensions
   Shortly after that, a popup will appear.

   For Ventura:
    - you might need to load the kext manually by entering cmd for the popup message to appear.
    - (macOS)$ sudo kextutil -v /Library/Extensions/VoodooHDA.kext

   (macOS) Go to System Settings > Security & Privacy > Security section
   (macOS) select 'App Store and identified developers' > Click the button 'Details...', enter your password
   (macOS) check the 'Unidentified - VoodooHDA - Updated', click OK and restart.


   Install Homebrew: https://brew.sh/
   (macOS)$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

   Install Pulseaudio
   (macOS)$ brew install pulseaudio
   (macOS)$ brew services start pulseaudio
   (macOS)$ brew services stop pulseaudio



```



