#!/bin/bash
#
# March 2018 xuzhenxing <xuzhenxing@canaan-creative.com>

# Mount img file
# Check offset value: fdisk -lu img-file
mount_img() {
    mkdir ./mount
    sudo mount -t auto -o loop,offset=$((94208*512)) ./2017-11-29-raspbian-stretch-lite.img ./mount
    sleep 1
}

# Git pyserial and auto test scripts
git_pyserial_scripts() {
    cd ./mount/home/pi
    git clone https://github.com/XzxEmbedded/pyserial.git
    git clone https://github.com/XzxEmbedded/miner-automate-test-scripts.git
    cd ../../../
    sleep 1
}

# Network config
network_config() {
    interface=`cat network.conf | grep interface`
    sudo sed -i "39 a $interface" ./mount/etc/dhcpcd.conf
    ip=`cat network.conf | grep ip_address`
    sudo sed -i "40 a $ip" ./mount/etc/dhcpcd.conf
    sleep 1
}

# Start ssh
start_ssh() {
    sudo sed -i '19 a \\t' ./mount/etc/rc.local
    sudo sed -i '19 a sudo /etc/init.d/ssh start' ./mount/etc/rc.local
    sleep 1
}

# Install expect
install_expect() {
    sudo sed -i '21 a \\t' ./mount/etc/rc.local
    sudo sed -i '21 a sudo apt-get install expect -y' ./mount/etc/rc.local
    sleep 1
}

# Umount img file
umount_img() {
    sudo umount ./mount
    rm -fr ./mount
}

# Help
show_help() {
    echo "\
    --help          Display help message
    --mount         Mount img file
    --git           After img file, git clone pyserial and auto test scripts
    --network       After img file, setting network
    --ssh           After img file, setting ssh
    --umount        Umount img file
    --all           Run all steps
    "
}

for conf in "$@"
do
    case $conf in
        --mount)
            mount_img
            ;;
        --git)
            git_pyserial_scripts
            ;;
        --network)
            network_config
            ;;
        --ssh)
            start_ssh
            ;;
        --expect)
            install_expect
            ;;
        --umount)
            umount_img
            ;;
        --all)
            mount_img && git_pyserial_scripts && start_ssh && install_expect && umount_img
            ;;
        --help)
            show_help
            ;;
        *)
            show_help
            ;;
    esac
done
