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

	options=("GNOME" "Mate" "Deepin" "XFCE4" "KDE " "LXQT" "Cinnamon" "TWM" "Έξοδος")
	select choice in "${options[@]}"

	do
    	case "$choice" in
		"GNOME")
                echo -e "Εγκατάσταση GNOME Desktop Environment ...\n"
                installer "GNOME Desktop" "gnome gnome-extra"
                sudo systemctl enable gdm
                ;;
             
		"Mate")
                echo -e "Εγκατάσταση Mate Desktop Environment ... \n"
                installer "Mate Desktop" "mate mate-extra"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                exit 0
                ;;
        "Deepin")
                echo -e "Εγκατάσταση Deepin Desktop Environment ...\n"
                installer "Deepin Desktop" "deepin deepin-extra"
                sudo systemctl enable lightdm
                exit 0
                ;;
        "XFCE4")
                echo -e "Εγκατάσταση XFCE Desktop Environment ... \n"
                installer "XFCE Desktop" "xfce4 xfce4-goodies"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"
                sudo systemctl enable lightdm
                exit 0
                ;;
        "KDE")
                echo -e "Εγκατάσταση KDE Desktop Environment ... \n"
                installer "KDE Desktop" "plasma-meta"
                sudo systemctl enable sddm
                exit 0
                ;;
        "LXQT")
                echo -e "Εγκατάσταση LXQT Desktop Environment ... \n"
                installer "LXQT Desktop" "lxqt breeze-icons"
                installer "SDDM Display Manager" "sddm"                
                sudo systemctl enable sddm
                exit 0
                ;;
        "Cinnamon")
                echo -e "Εγκατάσταση Cinnamon Desktop Environment ... \n"
                installer "Cinnamon Desktop" "cinnamon xterm"
                installer "LightDM Display Manager" "lightdm lightdm-gtk-greeter"                
                sudo systemctl enable lightdm
                exit 0
                ;;
        "TWM")
                echo -e "Εγκατάσταση TWM Desktop Environment ... \n"
                installer "TWM Desktop" "xorg-twm xterm xorg-xclock"
                installer "SDDM Display Manager" "sddm"                
                sudo systemctl enable sddm
                exit 0
                ;;                  
		"Έξοδος")
                echo -e "Έξοδος όπως επιλέχθηκε από το χρήστη "${USER}""
                exit 0
                ;;
            *)
                echo -e "${IRed}Οι επιλογές σας πρέπει να είναι [1 ~ 8]. Παρακαλώ προσπαθήστε ξανα!${NC}"
                
                ;;
        esac
	done

#    install_graphical_manager
else
    echo -e "${IRed}Γίνετε root μέσω του 'sudo -s' | 'sudo -i' | 'su' εντολών και δοκιμάστε ξανά ... ${NC}"
    exit 1
fi
