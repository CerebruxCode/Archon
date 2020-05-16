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
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
#IPurple='\033[0;95m'      # Not used yet Purple
ICyan='\033[0;96m'        # Not used yet Cyan
#IWhite='\033[0;97m'       # White
NC='\033[0m'

# Install Script
#
function installer() {
    echo -e "${IGreen}Εγκατάσταση $1 ...${NC}"
    if pacman -S $2
    then
        echo -e "${IGreen}[ ΕΓΙΝΕ ] Εγκατάσταση $1 ...${NC}"
    else
        echo -e "${IRed}[ ΑΠΕΤΥΧΕ ] Εγκατάσταση $1 ...${NC}"
    fi
}

if [ $UID -eq 0 ]
then
#    check_net_connection
#    install_xorg_server
    
    echo -e "Επιλέξτε ένα από τα διαθέσιμα γραφικά περιβάλλοντα: "
    echo -e "[1]  για  Mate    Desktop"
    echo -e "[2]  για  Gnome   Desktop"
    echo -e "[3]  για  Deepin  Desktop"
    echo -e "[4]  για  XFCE4   Desktop"

    read -p "Γράψτε την επιλογή σας [1, 2, 3, 4 ή exit] >>> " choice

    if [[ $choice =~ [1-4] ]] || [[ $choice == "exit" ]]
    then
        case "$choice" in
		1)
                echo -e "Εγκατάσταση Mate Desktop Environment ... \n"
                installer "Mate Desktop" "mate mate-extra"
				;;
		2)
                echo -e "Εγκατάσταση Gnome Desktop Environment ...\n"
                installer "Gnome Desktop" "gnome gnome-extra"
                ;;
        	3)
                echo -e "Εγκατάσταση Deepin Desktop Environment ...\n"
                install "Deepin Desktop" "deepin deepin-extra"
                ;;
        	4)
                echo -e "Εγκατάσταση XFCE Desktop Environment ... \n"
                install "XFCE Desktop" "xfce4 xfce4-goodies"
                ;;
		exit)
                echo -e "Έξοδος όπως επιλέχθηκε από τον χρήστη: '${USER}' ...\n$"
                exit 0
                ;;
            *)
                echo -e "${IRed}Οι επιλογές σας πρέπε να είναι [1 ~ 4]. Παρακαλώ προσπαθησε ξανα! ... Ματαίωση ...\n${NC}"
                exit 1
                ;;
        esac
    else
        echo -e "${ICyan}Οι επιλογές σας ήταν [1 Ή 2]. ΠΑΡΑΚΑΛΩ προσπαθησε ξανα! Ματαίωση ...\n${NC}"
        exit 1
    fi

#    install_graphical_manager
else
    echo -e "${IRed}Γίνετε root μέσω του 'sudo -s' | 'sudo -i' | 'su' εντολών και δοκιμάστε ξανά ... ${NC}"
    exit 1
fi
