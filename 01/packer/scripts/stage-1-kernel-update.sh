 #!/usr/bin/env bash   
sudo apt update && sudo apt install -y  build-essential flex bison dwarves libssl-dev libelf-dev libncurses-dev fakeroot 
uname -a
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.69.tar.xz
tar -xf linux-6.1.69.tar.xz
cd linux-6.1.69
cp -v /boot/config-$(uname -r) .config
make olddefconfig
yes | make localyesconfig
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS
scripts/config --set-str CONFIG_SYSTEM_TRUSTED_KEYS ""
scripts/config --set-str CONFIG_SYSTEM_REVOCATION_KEYS ""
fakeroot make -j$(grep -c processor /proc/cpuinfo)
sudo make modules_install
sudo make install
sudo update-grub