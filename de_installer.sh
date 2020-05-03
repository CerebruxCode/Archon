#!/bin/bash

# Exit codes for success || failure
#
OK=0
NOT_OK=1

# A few colors
#
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White
NC='\033[0m'


# Install X Dsiplay server (X-Org)
#
function install_xorg_server() {
    echo -e "${IGreen}         Installing X-Org Server ...${NC}"
    if pacman -S xorg xorg-server
    then
        echo -e "${IGreen}[ DONE ] Installing X-Org Server ...${NC}"
    else
        echo -e "${IRed}[ FAILED ] Installing X-Org Server ...${NC}"
    fi
}

#  Check Net Connection | If it is off , exit immediately
#
function check_net_connection() {
    ping -c 2 archlinux.org
    if [ $? -eq $OK ]
    then
        echo -e "${IYellow} Net connection seems activated ... Proceeding ...\n${NC}"
    else
        echo -e "${IRed} Net connection seems de-activated ... Aborting ...\n"
        echo -e "Please connect to Internet & Try again...\n Aborting now ... ${NC}"
        exit $NOT_OK
    fi
}

# Install MATE Desktop Environment in Arch Linux
#
function install_mate() {
    echo -e "${IGreen}         Updating repositories ...\n${NC}"
    if pacman -Syu
    then
        echo -e "${IGreen}[ DONE ] Updating repositories ...\n${NC}"
    else
        echo -e "${IRed}[ FAILED ] Updating repositories ...\n${NC}"
    fi

    echo -e "         Installing Mate DE & Mate extras ..."
    if pacman -S mate mate-extra
    then
        echo -e "${IGreen} [ DONE ] Installing Mate DE & Mate extras ... \n${NC}"
    else
        echo -e "${IRed} [ FAILED ] Installing Mate DE & Mate extras ... \n${NC}"
    fi
}


# Install GNOME Desktop Environment in Arch Linux
#
function install_gnome() {
    echo -e "${IGreen}         Updating repositories ...\n${NC}"
    if pacman -Syu
    then
        echo -e "${IGreen}[ DONE ] Updating repositories ...\n${NC}"
    else
        echo -e "${IRed}[ FAILED ] Updating repositories ...\n${NC}"
    fi

    echo -e "${IGreen}         Installing Gnome DE & Gnome extras ...${NC}"
    if pacman -S gnome gnome-extra
    then
        echo -e "${IGreen} [ DONE ] Installing Gnome DE & Gnome extras ... \n${NC}"
    else
        echo -e "${IRed} [ FAILED ] Installing Gnome DE & Gnome extras ... \n${NC}"
    fi
}

# Install Deepin Desktop Environment in Arch Linux
#
function install_deepin() {
    echo -e "${IGreen}         Updating repositories ...\n"
    if pacman -Syu
    then
        echo -e "${IGreen}[ DONE ] Updating repositories ...\n${NC}"
    else
        echo -e "${IRed}[ FAILED ] Updating repositories ...\n${NC}"
    fi

    echo -e "${IGreen}         Installing Deepin DE & Deepin extras ...${NC}"
    if pacman -S deepin deepin-extra
    then
        echo -e "${IGreen} [ DONE ] Installing Deepin DE & Deepin extras ... \n${NC}"
    else
        echo -e "${IRed} [ FAILED ] Installing Deepin DE & Deepin extras ... \n${NC}"
    fi
}

# Install XFCE4 Desktop Environment in Arch Linux
#
function install_xfce() {
    echo -e "${IGreen}         Updating repositories ...\n"
    if pacman -Syu
    then
        echo -e "${IGreen}[ DONE ] Updating repositories ...\n${NC}"
    else
        echo -e "${IRed}[ FAILED ] Updating repositories ...\n${NC}"
    fi

    echo -e "${IGreen}         Installing XFCE4 DE & XFCE4 goodies ...${NC}"
    if pacman -S xfce4 xfce4-goodies
    then
        echo -e "${IGreen} [ DONE ] Installing XFCE4 DE & XFCE4 goodies ... \n${NC}"
    else
        echo -e "${IRed} [ FAILED ] Installing XFCE4 DE & XFCE4 goodies ... \n${NC}"
    fi
}


# Install lightdm Display Manager
#
function install_graphical_manager() {
    echo -e " ${IGreen} Installing lightdm Display Manager ... \n${NC}"
    if pacman -S lightdm lightdm-gtk-greeter
    then
        echo -e "${IGreen} [ DONE ] Installing lightdm Display Manager ... \n${NC}"
    else 
        echo -e "${IRed} [ FAILED ] Installing lightdm Display Manager ... \n${NC}"
    fi

    echo -e "${ICyan} A few post actions | Creating symlinks ... \n${NC}"
    systemctl enable lightdm.service

    echo -e "${ICyan}After rebooting system You will be able to login to your Arch Linux Desktop Environment ... Ciao \n${NC}"
}

###########
## MAIN ##
#########
if [ $UID -eq $OK ]
then
    check_net_connection
    install_xorg_server
    
    echo -e "${IGreen}Please choose one of next Desktop Environments: \n"
    echo -e "'1'  for  Mate    Desktop \n"
    echo -e "'2'  for  Gnome   Desktop \n"
    echo -e "'3'  for  Deepin  Desktop\n"
    echo -e "'4'  for  XFCE4   Desktop${NC}\n"

    read -p "Type your choice [1, 2, 3, 4 OR exit] >>> " de_choice

    if [[ $de_choice =~ [1-4] ]] || [[ $de_choice == "exit" ]]
    then
        case "$de_choice" in
			1)
                echo -e "${IBlue} Start installing Mate Desktop Environment ... ${NC}\n"
                install_mate
				;;
			2)
                echo -e "${IBlue} Start installing Gnome Desktop Environment ... ${NC}\n"
                install_gnome
                ;;
            3)
                echo -e "${IBlue} Start installing Deepin Desktop Environment ... ${NC}\n"
                install_deepin
                ;;
            4)
                echo -e "${IBlue} Start installing XFCE Desktop Environment ... ${NC}\n"
                install_xfce
                ;;
            exit)
                echo -e "${ICyan}Exiting as chosen by user: '${USER}' ...\n${NC}"
                exit $OK
                ;;
            *)
                echo -e "${ICyan}Your choices were [1 ~ 4]. Please try again! Aborting ...\n${NC}"
                exit $NOT_OK
                ;;
        esac
    else
        echo -e "${ICyan}Your choices were [1 OR 2]. Please try again! Aborting ...\n${NC}"
        exit $NOT_OK
    fi

    install_graphical_manager
else 
    echo -e "${IYellow} Please become root via 'sudo -s' | 'sudo -i' | 'su' commands and try again... ${NC}"
    exit $NOT_OK
fi

echo -e "${IGreen} Finisihing ... \n${NC}"
echo -e "${IGreen} System is going to reboot now ...${NC}"
reboot now &>/dev/null
exit $OK
