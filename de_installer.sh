#!/bin/bash

# Exit codes για success || failure
#

setfont gr928a-8x16.psfu
OK=0
NOT_OK=1

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


# Install X Display server (X-Org)
#
function install_xorg_server() {
    echo -e "${IGreen}Εγκατάσταση X-Org Server ...${NC}"
    if pacman -S xorg xorg-server
    then
        echo -e "${IGreen}[ ΕΓΙΝΕ ] Εγκατάσταση X-Org Server ...${NC}"
    else
        echo -e "${IRed}[ ΑΠΕΤΥΧΕ ] Εγκατάσταση X-Org Server ...${NC}"
    fi
}

#  Check Net Connection | If it is off , exit immediately
#
function check_net_connection() {
    sleep 1
    echo '---------------------------------------'
    echo ' Έλεγχος σύνδεσης στο διαδίκτυο        '
    echo '---------------------------------------'
    if ping -c 3 www.google.com &> /dev/null; then

        echo -e "${IYellow} Η σύνδεση στο διαδίκτυο φαίνεται ενεργοποιημένη...Προχωράμε...\n${NC}"
    else
        echo -e "${IRed} Η σύνδεση στο Διαδίκτυο φαίνεται απενεργοποιημένη ... Ματαίωση ...\n"
        echo -e "Συνδεθείτε στο Διαδίκτυο και δοκιμάστε ξανά ... \n Ματαίωση...${NC}"
        exit $NOT_OK
    fi
}

# Install MATE Desktop Environment in Arch Linux
#
function install_mate() {
    echo -e "${IGreen}Ενημέρωση αποθετηρίων ...\n${NC}"
    if pacman -Syu
    then
        echo -e "${IGreen}[ ΕΓΙΝΕ ] Ενημέρωση αποθετηρίων ...\n${NC}"
    else
        echo -e "${IRed}[ ΑΠΕΤΥΧΕ ] Ενημέρωση αποθετηρίων ...\n${NC}"
    fi

    echo -e "Εγκατάσταση Mate DE & Mate extras ..."
    if pacman -S mate mate-extra
    then
        echo -e "${IGreen}[ ΕΓΙΝΕ ] Εγκατάσταση Mate DE & Mate extras ... \n${NC}"
    else
        echo -e "${IRed}[ ΑΠΕΤΥΧΕ ] Εγκατάσταση Mate DE & Mate extras ... \n${NC}"
    fi
}


# Install GNOME Desktop Environment in Arch Linux
#
function install_gnome() {
    echo -e "${IGreen}Ενημέρωση αποθετηρίων ...\n${NC}"
    if pacman -Syu
    then
        echo -e "${IGreen}[ ΕΓΙΝΕ ] Ενημέρωση αποθετηρίων ...\n${NC}"
    else
        echo -e "${IRed}[ ΑΠΕΤΥΧΕ ] Ενημέρωση αποθετηρίων ...\n${NC}"
    fi

    echo -e "${IGreen}Εγκατάσταση Gnome DE & Gnome extras ...${NC}"
    if pacman -S gnome gnome-extra
    then
        echo -e "${IGreen} [ ΕΓΙΝΕ ] Εγκατάσταση Gnome DE & Gnome extras ... \n${NC}"
    else
        echo -e "${IRed} [ ΑΠΕΤΥΧΕ ] Εγκατάσταση Gnome DE & Gnome extras ... \n${NC}"
    fi
}

# Install Deepin Desktop Environment in Arch Linux
#
function install_deepin() {
    echo -e "${IGreen}Ενημέρωση αποθετηρίων ...\n"
    if pacman -Syu
    then
        echo -e "${IGreen}[ ΕΓΙΝΕ ] Ενημέρωση αποθετηρίων ...\n${NC}"
    else
        echo -e "${IRed}[ ΑΠΕΤΥΧΕ ] Ενημέρωση αποθετηρίων ...\n${NC}"
    fi

    echo -e "${IGreen}Εγκατάσταση Deepin DE & Deepin extras ...${NC}"
    if pacman -S deepin deepin-extra
    then
        echo -e "${IGreen} [ ΕΓΙΝΕ ] Εγκατάσταση Deepin DE & Deepin extras ... \n${NC}"
    else
        echo -e "${IRed} [ ΑΠΕΤΥΧΕ ] Εγκατάσταση Deepin DE & Deepin extras ... \n${NC}"
    fi
}

# Install XFCE4 Desktop Environment in Arch Linux
#
function install_xfce() {
    echo -e "${IGreen}Ενημέρωση αποθετηρίων ...\n"
    if pacman -Syu
    then
        echo -e "${IGreen}[ ΕΓΙΝΕ ] Ενημέρωση αποθετηρίων ...\n${NC}"
    else
        echo -e "${IRed}[ ΑΠΕΤΥΧΕ ] Ενημέρωση αποθετηρίων ...\n${NC}"
    fi

    echo -e "${IGreen}         Εγκατάσταση XFCE4 DE & XFCE4 goodies ...${NC}"
    if pacman -S xfce4 xfce4-goodies
    then
       echo -e "${IGreen}[ ΕΓΙΝΕ ] Εγκατάσταση XFCE4 DE & XFCE4 goodies ... \n${NC}"
    else
       echo -e "${IRed}[ ΑΠΕΤΥΧΕ ] Εγκατάσταση XFCE4 DE & XFCE4 goodies ... \n${NC}"
    fi
}


# Install lightdm Display Manager
#
function install_graphical_manager() {
    echo -e " ${IGreen}Εγκατάσταση lightdm Display Manager ... \n${NC}"
    if pacman -S lightdm lightdm-gtk-greeter
    then
        echo -e "${IGreen}[ ΕΓΙΝΕ ] Εγκατάσταση lightdm Display Manager ... \n${NC}"
    else 
        echo -e "${IRed}[ ΑΠΕΤΥΧΕ ] Εγκατάσταση lightdm Display Manager ... \n${NC}"
    fi

    echo -e "${ICyan} Μερικές ενέργειες ακόμα | Ενεργοποίηση αυτόματης εκκίνησης ... \n${NC}"
    systemctl enable lightdm.service

    echo -e "${ICyan} Μετά την επανεκκίνηση του συστήματος, Θα μπορείτε να συνδεθείτε στο Γραφικό περιβάλλον του Arch Linux ... Γειά ! \n${NV}"
}

###########
## MAIN ##
#########
if [ $UID -eq $OK ]
then
    check_net_connection
    install_xorg_server
    

    echo -e "${IGreen}Επιλέξτε ένα από τα επόμενα περιβάλλοντα επιφάνειας εργασίας: \n"
    echo -e "'1'  για  Mate    Desktop \n"
    echo -e "'2'  για  Gnome   Desktop \n"
    echo -e "'3'  για  Deepin  Desktop\n"
    echo -e "'4'  για  XFCE4   Desktop${NC}\n"
    read -p "Γράψτε την επιλογή σας [1, 2, 3, 4 ή exit] >>> " de_choice

    if [[ $de_choice =~ [1-4] ]] || [[ $de_choice == "exit" ]]
    then
        case "$de_choice" in
			      1)
                echo -e "${IBlue} Εγκατάσταση Mate Desktop Environment ... ${NC}\n"
                install_mate
				         ;;
			      2)
                echo -e "${IBlue} Εγκατάσταση Gnome Desktop Environment ... ${NC}\n"
                install_gnome
                ;;
            3)
                echo -e "${IBlue} Εγκατάσταση Deepin Desktop Environment ... ${NC}\n"
                install_deepin
                ;;
            4)
                echo -e "${IBlue} Εγκατάσταση XFCE Desktop Environment ... ${NC}\n"
                install_xfce
                ;;
            exit)
                echo -e "${ICyan} Έξοδος όπως επιλέχθηκε από τον χρήστη: '${USER}' ...\n${NC}"
                exit $OK
                ;;
            *)
                echo -e "${ICyan} Οι επιλογές σας πρέπε να είναι [1 ~ 4]. Παρακαλώ προσπαθησε ξανα! ... Ματαίωση ...\n${NC}"

                exit $NOT_OK
                ;;
        esac
    else
        echo -e "${ICyan}Οι επιλογές σας ήταν [1 Ή 2]. ΠΑΡΑΚΑΛΩ προσπαθησε ξανα! Ματαίωση ...\n${NC}"
        exit $NOT_OK
    fi

    install_graphical_manager
else
    echo -e "${IRed}Γίνετε root μέσω του 'sudo -s' | 'sudo -i' | 'su' εντολών και δοκιμάστε ξανά ... ${NC}"
    exit $NOT_OK
fi

echo -e "${IGreen}Ολοκλήρωση ... \n${NC}"
echo -e "${IGreen}Το σύστημα πρόκειται να επανεκκινήσει ...${NC}"
#sleep 3
#reboot now &>/dev/null
exit $OK