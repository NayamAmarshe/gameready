#!/usr/bin/env bash

# COLOR VARIABLES
RED="\e[31m"
ENDCOLOR="\e[0m"

# SHOW INITIAL DIALOGS
zenity --info --text="Script made by Nayam Amarshe for the Lunix YouTube channel" --no-wrap
zenity --warning --width 300 --title="Before Starting the Installation" --text="You may see a text asking for your password, just enter your password in the terminal. The password is for installing system libraries, so root access is required by GameReady. When you enter your password, do not worry if it doesn't show you what you typed, it's totally normal."

# CHECK IF WINE IS INSTALLED
if [[ ! -f /usr/bin/wine ]]; then
	# INSTALL WINE
	echo -e "\n\n${RED}<-- Installing WINE -->${ENDCOLOR}"
	sudo dpkg --add-architecture i386
	sudo wget -nc -O /usr/share/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key

	# REMOVE PREVIOUS WINE PPA IF PRESENT
	for list in /etc/apt/sources.list.d/{winehq*,wine*}
	do
		sudo rm "$list"
	done

	if [[ $(lsb_release -si) == "Ubuntu" ]]; then
		# GET UBUNTU VERSION
		ubuntuVersion=$(lsb_release -sc)
		version=$ubuntuVersion
		distro=ubuntu
	elif [[ $(lsb_release -si) == "Debian" ]]; then
		# GET DEBIAN VERSION
		debianVersion=$(lsb_release -sc)
		version=$debianVersion
		distro=debian
	fi
	sudo wget -nc -P /etc/apt/sources.list.d/ "https://dl.winehq.org/wine-builds/$distro/dists/${version}/winehq-${version}.sources"
	sudo apt -y update
	sudo apt install -y --install-recommends winehq-stable
else
	echo -e "\n\n${RED}<-- WINE is installed... Skipping -->${ENDCOLOR}"
fi

# CHECK IF WINETRICKS IS INSTALLED
if [[ ! -f /usr/bin/winetricks ]]; then
	# INSTALL WINETRICKS
	echo -e "\n\n${RED}<-- Installing Winetricks -->${ENDCOLOR}"
	cd || {
		echo "Failed at command cd"
		exit 1
	}
	sudo apt install -y winetricks
	zenity --warning --width 300 --text="Winetricks is now installed but to keep it on latest version at all times, we'll ask Winetricks to self-update. Just press Y and press enter."
	sudo winetricks --self-update
else
	echo -e "\n\n${RED}<-- Winetricks is installed... Skipping -->${ENDCOLOR}"
fi

# CHECK IF LUTRIS IS INSTALLED
if [[ ! -f /usr/games/lutris ]]; then
	# INSTALL LUTRIS
	echo -e "\n\n${RED}<-- Installing Lutris -->${ENDCOLOR}"
	if [[ $(lsb_release -si) == "Ubuntu" ]]; then
		sudo add-apt-repository -y ppa:lutris-team/lutris
	elif [[ $(lsb_release -si) == "Debian" ]]; then
		echo "deb https://download.opensuse.org/repositories/home:/strycore/Debian_11/ ./" | sudo tee /etc/apt/sources.list.d/lutris.list
		wget -q https://download.opensuse.org/repositories/home:/strycore/Debian_11/Release.key -O- | sudo tee /etc/apt/trusted.gpg.d/lutris.asc
	fi
	sudo apt -y update
	sudo apt -y install lutris
else
	echo -e "\n\n${RED}<-- Lutris is installed... Skipping -->${ENDCOLOR}"
fi

# CHECK IF GAMEMODE IS INSTALLED
if [[ ! -f /usr/bin/gamemoded ]]; then
	# INSTALL GAMEMODE
	echo -e "\n\n${RED}<-- Installing Gamemode -->${ENDCOLOR}"
	sudo apt -y install meson libsystemd-dev pkg-config ninja-build git libdbus-1-dev libinih-dev build-essential
	git clone https://github.com/FeralInteractive/gamemode.git
	cd gamemode || {
		echo "Failed at command cd gamemode"
		exit 1
	}
	latestVersion=$(git ls-remote --tags https://github.com/FeralInteractive/gamemode.git | tail -n 1 | cut -d/ -f3-);
	git checkout "$latestVersion"
	zenity --warning --width 300 --title="Before Starting the Installation" --text="You'll be asked something like 'Install to /usr?', just press the Y key and hit enter!"
	./bootstrap.sh
	rm -rf gamemode
else
	echo -e "\n\n${RED}<-- Gamemode is installed... Skipping -->${ENDCOLOR}"
fi

# CHECK IF XANMOD IS INSTALLED
if ! uname -r | grep "xanmod" >/dev/null 2>&1; then
	# INSTALL XANMOD KERNEL
	if zenity --question --width 300 --title="Install Xanmod Kernel?" --text="Your current kernel is $(uname -r). We're going to install Xanmod kernel next, Xanmod is for enabling extra performance patches for kernels and this step is required for kernels below v5.16. Do you want to install Xanmod?"; then
		{
			echo -e "\n\n${RED}<-- Installing Xanmod Kernel -->${ENDCOLOR}"
			echo 'deb [signed-by=/usr/share/keyrings/xanmod-kernel-archive-keyring.gpg] http://deb.xanmod.org releases main' |
			sudo tee /etc/apt/sources.list.d/xanmod-kernel.list && wget -qO - https://dl.xanmod.org/gpg.key |
			sudo apt-key --keyring /usr/share/keyrings/xanmod-kernel-archive-keyring.gpg add -
			sudo apt update && sudo apt install linux-xanmod -y
			zenity --info --width 200 --title="Success" --text="Xanmod kernel installed! Make sure to reboot after all the script finishes its work."
		}
	fi
else
  echo -e "\n\n${RED}<-- Xanmod is installed... Skipping -->${ENDCOLOR}"
fi

# CHECK IF WINETRICKS IS INSTALLED
if [[ -f /usr/bin/winetricks ]]; then
	# INSTALL WINETRICKS DEPENDENCIES
	zenity --warning --title="Alright Listen Up" --width 300 --text="Now we're going to install dependencies for WINE like DirectX, Visual C++, DotNet and more. Winetricks will try to install these dependencies for you, so it'll take some time. Do not panic if you don't receive visual feedback, it'll take time."
	echo -e "\n\n${RED}<-- Installing Important WINE Helpers -->${ENDCOLOR}"
	winetricks -q -v d3dx10 d3dx9 dotnet35 dotnet40 dotnet45 dotnet48 dxvk vcrun2008 vcrun2010 vcrun2012 vcrun2019 vcrun6sp6
fi

zenity --info --title="Success" --text="All done! Enjoy!"
