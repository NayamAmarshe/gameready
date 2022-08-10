#!/bin/bash

RED="\e[31m"
ENDCOLOR="\e[0m"

zenity --info --text="Script made by Nayam Amarshe for the Lunix YouTube channel" --no-wrap
zenity --warning --width 300 --title="Before Starting the Installation" --text="You may see a text asking for your password, just enter your password in the terminal. You do not worry if it doesn't show you what you typed, it's normal."

# INSTALL WINE
echo -e "\n\n${RED}<-- Installing WINE -->${ENDCOLOR}"
sudo dpkg --add-architecture i386
sudo wget -nc -O /usr/share/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

# REMOVE PREVIOUS WINE PPA IF PRESENT
sudo rm /etc/apt/sources.list.d/winehq*

# GET UBUNTU VERSION
ubuntuVersion=$(lsb_release -sc)
sudo wget -nc -P /etc/apt/sources.list.d/ "https://dl.winehq.org/wine-builds/ubuntu/dists/${ubuntuVersion}/winehq-${ubuntuVersion}.sources"
sudo apt -y update
sudo apt install -y --install-recommends winehq-stable

# INSTALL WINETRICKS
echo -e "\n\n${RED}<-- Installing Winetricks -->${ENDCOLOR}"
cd || {
	echo "Failed at command cd"
	exit 1
}
wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks
sudo cp winetricks /usr/local/bin

# INSTALL LUTRIS
echo -e "\n\n${RED}<-- Installing Lutris -->${ENDCOLOR}"
sudo add-apt-repository -y ppa:lutris-team/lutris
sudo apt -y update
sudo apt -y install lutris

# INSTALL Gamemode
echo -e "\n\n${RED}<-- Installing Gamemode -->${ENDCOLOR}"
rm -rf gamemode
sudo apt -y install meson libsystemd-dev pkg-config ninja-build git libdbus-1-dev libinih-dev build-essential
git clone https://github.com/FeralInteractive/gamemode.git
cd gamemode || {
	echo "Failed at command cd gamemode"
	exit 1
}
git checkout 1.7 # omit to build the master branch
zenity --warning --width 300 --title="Before Starting the Installation" --text="You'll be asked something like 'Install to /usr?', just press the Y key and hit enter!"
./bootstrap.sh

# XANMOD KERNEL
if zenity --question --width 300 --title="Install Xanmod Kernel?" --text="Your current kernel is $(uname -r). We're going to install Xanmod kernel next, Xanmod is for enabling extra performance patches for kernels and this step is required for kernels below v5.16. Do you want to install Xanmod?"; then
	{
		echo -e "\n\n${RED}<-- Installing Xanmod Kernel -->${ENDCOLOR}"
		echo 'deb http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list
		wget -qO - https://dl.xanmod.org/gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg add -
		sudo apt update && sudo apt install linux-xanmod -y
		zenity --info --width 200 --title="Success" --text="Xanmod kernel installed! Make sure to reboot after all the script finishes its work."
	}
fi

# INSTALL WINETRICKS DEPENDENCIES
zenity --warning --title="Alright Listen Up" --width 300 --text="Now we're going to install dependencies for WINE like DirectX, Visual C++, DotNet and more. Winetricks will try to install these dependencies for you, so it'll take some time. Do not panic if you don't receive visual feedback, it'll take time."
echo -e "\n\n${RED}<-- Installing Important WINE Helpers -->${ENDCOLOR}"
winetricks -q -v d3dx10 d3dx9 dotnet35 dotnet40 dotnet45 dotnet48 dxvk vcrun2008 vcrun2010 vcrun2012 vcrun2019 vcrun6sp6

zenity --info --title="Success" --text="All done! Enjoy!"
