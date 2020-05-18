#!/bin/bash
#
#
# Archon -- Ελληνικός Arch Linux Installer
# Copyright (c)2017 Vasilis Niakas, Salih Emin and Contributors
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 3 of the License.
#
# Please read the file LICENSE, README and AUTHORS for more information.
#
#

# Exit codes για success || failure
#
setfont gr928a-8x16.psfu


# A few colors
#
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
# IYellow='\033[0;93m'      # Not used yet Yellow
# IBlue='\033[0;94m'        # Not used yet Blue
# IPurple='\033[0;95m'      # Not used yet Purple
# ICyan='\033[0;96m'        # Not used yet Cyan
# IWhite='\033[0;97m'       # White
NC='\033[0m'

# Install Script
#
function check_if_in_VM() {
    echo -e "${IGreen}Έλεγχος περιβάλλοντος (PC | VM) ...${NC}"
    sleep 2
    pacman -S --noconfirm facter
    if [[ $(facter 2>/dev/null | grep 'is_virtual' | awk -F'=> ' '{print $2}') == true ]]; then
        echo -e "${IGreen}Είμαστε σε VM (VirtualBox | VMware) ...${NC}"
		sleep 2
        pacman -S --noconfirm virtualbox-guest-dkms linux-headers xf86-video-vmware 
    else
        echo -e "${IGreen}Δεν είμαστε σε VM (VirtualBox | VMware) ...${NC}"
		sleep 2
        pacman -Rs --noconfirm facter
    fi
    sleep 2
}


function installer() {
    echo -e "${IGreen}Εγκατάσταση $1 ...${NC}"
    if pacman -S --noconfirm $2
    then
        echo -e "${IGreen}[ ΕΠΙΤΥΧΗΣ ] Εγκατάσταση $1 ...${NC}"
    else
        echo -e "${IRed}[ ΑΠΕΤΥΧΕ ] Εγκατάσταση $1 ...${NC}"
    fi
}

if [ $UID -eq 0 ]
then
#    check_net_connection
    check_if_in_VM  # Ελέγχουμε αν είναι σε VM (Virtualbox/VMware)
    installer "Xorg Server" "xorg xorg-server xorg-xinit alsa-utils pulseaudio noto-fonts"		# Εγκατάσταση Xorg Server
    PS3='Επιλέξτε ένα από τα διαθέσιμα γραφικά περιβάλλοντα : '

	options=("GNOME" "Mate" "Deepin" "Xfce" "KDE" "LXQt" "Cinnamon" "Budgie" "i3" "Enlightenment" "UKUI" "Fluxbox" "Sugar" "Twm" "Έξοδος")
	select choice in "${options[@]}"

	do
    	case "$choice" in
		"GNOME")
                echo -e "Εγκατάσταση GNOME Desktop Environment ...\n"
                installer "GNOME Desktop" "gnome gnome-extra"
                sudo systemctl enable gdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
 		"Mate")
                echo -e "Εγκατάσταση Mate Desktop Environment ... \n"
                installer "Mate Desktop" "mate mate-extra networkmanager network-manager-applet"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Deepin")
                echo -e "Εγκατάσταση Deepin Desktop Environment ...\n"
                installer "Deepin Desktop" "deepin deepin-extra networkmanager"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Xfce")
                echo -e "Εγκατάσταση Xfce Desktop Environment ... \n"
                installer "Xfce Desktop" "xfce4 xfce4-goodies pavucontrol networkmanager network-manager-applet"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "KDE")
                echo -e "Εγκατάσταση KDE Desktop Environment ... \n"
                installer "KDE Desktop" "plasma-meta konsole dolphin"
                sudo systemctl enable sddm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "LXQt")
                echo -e "Εγκατάσταση LXQt Desktop Environment ... \n"
                installer "LXQt Desktop" "lxqt breeze-icons"
                installer "SDDM Display Manager" "sddm"                
                sudo systemctl enable sddm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Cinnamon")
                echo -e "Εγκατάσταση Cinnamon Desktop Environment ... \n"
                installer "Cinnamon Desktop" "cinnamon xterm networkmanager"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"                
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Budgie")
                echo -e "Εγκατάσταση Budgie Desktop Environment ... \n"
                installer "Budgie Desktop" "budgie-desktop budgie-extras xterm networkmanager network-manager-applet"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "i3")
                echo -e "Εγκατάσταση i3 Desktop Environment ... \n"
                installer "i3 Desktop" "i3 dmenu"
                exit 0
                ;;
        "Enlightenment")
                echo -e "Εγκατάσταση Enlightenment Desktop Environment ... \n"
                installer "Enlightenment Desktop" "enlightenment terminology connman"
                installer "LightDM Display Manager" "lightdm"
                sudo systemctl enable lightdm
                sudo systemctl enable connman.service
                exit 0
                ;;
        "UKUI")
                echo -e "Εγκατάσταση UKUI Desktop Environment ... \n"
                installer "UKUI Desktop" "ukui xterm networkmanager network-manager-applet"
                sudo systemctl enable lightdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Fluxbox")
                echo -e "Εγκατάσταση Fluxbox Desktop Environment ... \n"
                installer "Fluxbox Desktop" "fluxbox xterm mmaker network-manager-applet"
                installer "LXDM Display Manager" "lxdm"
                sudo systemctl enable lxdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Sugar")
                echo -e "Εγκατάσταση Sugar Desktop Environment ... \n"
                installer "Sugar Desktop" "sugar sugar-fructose xterm"
                installer "LXDM Display Manager" "lxdm"
                sudo systemctl enable lxdm
                sudo systemctl enable NetworkManager
                exit 0
                ;;
        "Twm")
                echo -e "Εγκατάσταση Twm Desktop Environment ... \n"
                installer "Twm Desktop" "xorg-twm xterm xorg-xclock xorg-xinit"
                exit 0
                ;;
		"Έξοδος")
                echo -e "Έξοδος όπως επιλέχθηκε από το χρήστη "${USER}""
                exit 0
                ;;
            *)
                echo -e "${IRed}Οι επιλογές σας πρέπει να είναι [1 ~ 13]. Παρακαλώ προσπαθήστε ξανα!${NC}"
                ;;
        esac
	done
else
    echo -e "${IRed}Γίνετε root μέσω του 'sudo -s' | 'sudo -i' | 'su' εντολών και δοκιμάστε ξανά ... ${NC}"
    exit 1
fi
