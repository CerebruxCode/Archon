#!/bin/bash

#############################################################
#
# Author : dimos katsimardos
# Date   : 10/05/2020 | Bug Year
# Description : Just a helper script to be run after
#               installing Arch Linux in order to install
#               some basic programs for basic stuff
#
#############################################################


# Exit codes για success || failure
#
# setfont gr928a-8x16.psfu
OK=0
NOT_OK=1
INTERNET_CONNECTION_ERROR=2

# A few colors
#
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
ICyan='\033[0;96m'        # Not used yet Cyan
IBlue='\033[0;94m'        # Blue
NC='\033[0m'              # No Color

#  Check Net Connection | If it is off , exit immediately
#
function check_net_connection() {
    sleep 1
    echo '---------------------------------------'
    echo ' Έλεγχος σύνδεσης στο διαδίκτυο        '
    echo '---------------------------------------'
    if ping -c 3 www.google.com &> /dev/null; then
        echo -e "${IYellow} Η σύνδεση στο διαδίκτυο φαίνεται ενεργοποιημένη...Προχωράμε...\n${NC}"
        return $OK
    else
        echo -e "${IRed} Η σύνδεση στο Διαδίκτυο φαίνεται απενεργοποιημένη ... Ματαίωση ...\n"
        echo -e "Συνδεθείτε στο Διαδίκτυο και δοκιμάστε ξανά ... \n Ματαίωση...${NC}"
        return $INTERNET_CONNECTION_ERROR
    fi
}


# Install a music player | For now #2 options : Clementine | Audacious
#
function install_music_player() {
    echo -e "${IGreen}Επιλέξτε ένα από τα επόμενα προγράμματα αναπαραγωγής μουσικής : \n"
    echo -e "'1'  για  Clementine  Music  Player \n"
    echo -e "'2'  για  Audacious   Music  Player \n"
    
    read -p "Γράψτε την επιλογή σας [1, 2 ή exit] >>> " mp_choice

    if [[ $mp_choice =~ [1-2] ]] || [[ $mp_choice == "exit" ]]
    then
        case "$mp_choice" in
			1)
                echo -e "${IBlue} Εγκατάσταση Clementine Music Player ... ${NC}\n"
                if pacman -S clementine
                then
                    # Sweet, installed clementine
                    echo -e "${IYellow} [ ΕΓΙΝΕ ] Εγκατάσταση Clementine Music Player  ... ${NC}\n"
                    return $OK
                else
                    # Oops, failure during clementine installation
                    echo -e "${IRed} [ ΑΠΟΤΥΧΙΑ ] Εγκατάσταση Clementine Music Player  ... ${NC}\n"
                    return $NOT_OK
                fi
				;;
			2)
                echo -e "${IBlue} Εγκατάσταση Audacious Music Player ... ${NC}\n"
                if pacman -S audacious
                then
                    # Sweet, installed audacious
                    echo -e "${IYellow} [ ΕΓΙΝΕ ] Εγκατάσταση Audacious Music Player  ... ${NC}\n"
                    return $OK
                else
                    # Oops, failure during audacious installation
                    echo -e "${IRed} [ ΑΠΟΤΥΧΙΑ ] Εγκατάσταση Audacious Music Player  ... ${NC}\n"
                    return $NOT_OK
                fi
                ;;
            exit)
                echo -e "${ICyan} Έξοδος όπως επιλέχθηκε από τον χρήστη: '${USER}' ...\n${NC}"
                return $OK
                ;;
            *)
                echo -e "${ICyan}\nΟι επιλογές σας πρέπε να είναι [1 ~ 2]. Παρακαλώ προσπάθησε ξανά τώρα!\n${NC}"
                sleep 3
                clear
                install_music_player
                ;;
        esac
    else
        echo -e "${ICyan}\nΟι επιλογές σας ήταν [1 ή 2]. ΠΑΡΑΚΑΛΩ προσπάθησε ξανά!\n${NC}"
        sleep 3
        clear
        install_music_player
    fi
    return $OK
}

# Install a media player | For now #2 options : VLC | MPV
#
function install_media_player() {
    echo -e "${IGreen}Επιλέξτε ένα από τα επόμενα προγράμματα αναπαραγωγής πολυμέσων : \n"
    echo -e "'1'  για  VLC   Media  Player \n"
    echo -e "'2'  για  MPV   Media  Player \n"
    
    read -p "Γράψτε την επιλογή σας [1, 2 ή exit] >>> " mp_choice

    if [[ $mp_choice =~ [1-2] ]] || [[ $mp_choice == "exit" ]]
    then
        case "$mp_choice" in
			1)
                echo -e "${IBlue} Εγκατάσταση VLC Media Player ... ${NC}\n"
                if pacman -S vlc
                then
                    # Sweet, installed clementine
                    echo -e "${IYellow} [ ΕΓΙΝΕ ] Εγκατάσταση VLC Media Player  ... ${NC}\n"
                    return $OK
                else
                    # Oops, failure during clementine installation
                    echo -e "${IRed} [ ΑΠΟΤΥΧΙΑ ] Εγκατάσταση VLC Media Player  ... ${NC}\n"
                    return $NOT_OK
                fi
				;;
			2)
                echo -e "${IBlue} Εγκατάσταση MPV Media Player ... ${NC}\n"
                if pacman -S mpv
                then
                    # Sweet, installed audacious
                    echo -e "${IYellow} [ ΕΓΙΝΕ ] Εγκατάσταση MPV Media Player  ... ${NC}\n"
                    return $OK
                else
                    # Oops, failure during audacious installation
                    echo -e "${IRed} [ ΑΠΟΤΥΧΙΑ ] Εγκατάσταση MPV Media Player  ... ${NC}\n"
                    return $NOT_OK
                fi
                ;;
            exit)
                echo -e "${ICyan} Έξοδος όπως επιλέχθηκε από τον χρήστη: '${USER}' ...\n${NC}"
                exit $OK
                ;;
            *)
                echo -e "${ICyan}\nΟι επιλογές σας πρέπε να είναι [1 ~ 2]. Παρακαλώ προσπάθησε ξανά τώρα! ... \n${NC}"
                sleep 3
                clear
                install_media_player
                ;;
        esac
    else
        echo -e "${ICyan}\nΟι επιλογές σας ήταν [1 ή 2]. ΠΑΡΑΚΑΛΩ προσπάθησε ξανά! ...\n${NC}"
        sleep 3
        clear
        install_media_player
    fi
    return $OK
}


function main() {
    # If user is not the super-user, then abort
    #
    if [ $UID -ne $OK ]
    then
        echo -e "${IRed} Γίνετε root μέσω του 'sudo -s' | 'sudo -i' | 'su' εντολών και δοκιμάστε ξανά ... ${NC}"
        exit $NOT_OK
    else
        check_net_connection
        if [ $? -eq $INTERNET_CONNECTION_ERROR ]
        then
            echo -e "${IRed} Συνδεθείτε στο διαδίκτυο και προσπαθήστε ξανά. ${NC}\n"
            exit $NOT_OK
        else
            echo -e "${ICyan} Ξεκινάμε με την εγκατάσταση ενός Music Player ...${NC}\n"
            # 1st: Install a Music Player
            #
            install_music_player
            echo -e "${ICyan} Would You like to continue? Type 'y' for Yes OR 'n' for NO :\n"
            read -p "Γράψτε την επιλογή σας [ y | n ] >>> " continue_or_not
            if [ "$continue_or_not" == "y" ]
            then
                echo -e "${ICyan}Continuing with Media Player Installation ... ${NC}\n"
            else
                echo -e "${IRed}Aborting after user's choice ...${NC}\n"
                exit $OK
            fi
            # 2nd: Install A Media Player
            #
            install_media_player
        fi
    fi
}


#############
### MAIN ###
###########

# Start main function
#
main