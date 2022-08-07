#!/bin/bash

if [ $EUID != 0 ]; then
	zenity --info --text="Script made by Nayam Amarshe for the Lunix YouTube channel" --no-wrap
	zenity --info --title="Before Starting the Installation" --text="Please enter your password" --no-wrap
	sudo "$0" "$@"
	exit $?
fi

# INSTALL WINE
echo "Installing WINE"
sudo dpkg --add-architecture i386
sudo wget -nc -O /usr/share/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
# GET UBUNTU VERSION
ubuntuVersion=$(lsb_release -sc)
sudo wget -nc -P /etc/apt/sources.list.d/ "https://dl.winehq.org/wine-builds/ubuntu/dists/${ubuntuVersion}/winehq-${ubuntuVersion}.sources"
sudo apt -y update
sudo apt install -y --install-recommends winehq-stable

# INSTALL WINETRICKS
echo "Installing Winetricks"
cd || {
	echo "Failed at command cd"
	exit 1
}
wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks
sudo cp winetricks /usr/local/bin

# INSTALL LUTRIS
echo "Installing Lutris"
sudo add-apt-repository -y ppa:lutris-team/lutris
sudo apt -y update
sudo apt -y install lutris

# INSTALL LUTRIS
echo "Installing Gamemode"
sudo apt -y install meson libsystemd-dev pkg-config ninja-build git libdbus-1-dev libinih-dev build-essential
git clone https://github.com/FeralInteractive/gamemode.git
cd gamemode || {
	echo "Failed at command cd gamemode"
	exit 1
}
git checkout 1.7 # omit to build the master branch
./bootstrap.sh

# XANMOD KERNEL
if zenity --question --title="Install Xanmod Kernel?" --text="Your current kernel is $(uname -r). We're going to install Xanmod kernel next but Xanmod is for enabling extra performance patches for kernels and this step is required for kernels below v5.16. Do you want to install Xanmod?"; then
	{
		echo 'deb http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
		wget -qO - https://dl.xanmod.org/gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg add -
		sudo apt update && sudo apt install linux-xanmod
		zenity --info --title="Success" --text="Xanmod kernel installed! Make sure to reboot after all the script finishes its work."
	}
fi

# WINETRICKS DEPENDENCIES
zenity --info --title="Alright Listen Up" --text="Now we're going to install dependencies for WINE like DirectX, Visual C++, DotNet and more. Winetricks will try to install these dependencies for you, so it'll take some time. Do not panic if you don't receive visual feedback, it'll take time."
winetricks -q -v d3dx10 d3dx9 dotnet35 dotnet40 dotnet45 dotnet48 dxvk vcrun2008 vcrun2010 vcrun2012 vcrun2019 vcrun6sp6

zenity --info --title="Success" --text="All done! Enjoy!"
