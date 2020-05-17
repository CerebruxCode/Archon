#!/bin/bash

#############################################################
#
# Author      : dimos katsimardos
# Date        : 10/05/2020 | Bug Year
# Description : Just a helper script to be run after
#               installing Arch Linux in order to install
#               some basic programs for basic stuff
#
# Version 1.0 : Option to install music player, media player,
#               Internet Explorer, Email Client, Text editor
#
# NOTE : If this program does not run after sftp from Win PC
#        to VM for example, install dos2unix utility, via
#        'sudo pacman -S dos2unix'. Also, if bash is not
#        installed in the DE, for example Deepin Desktop, then
#        also install bash via 'sudo pacman -S bash'.
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

#
# Template install function for installing one of two options of two programs | for now at least
#
function install() {
    # Program to install : audacious -> 1st arg | clementine -> 2nd arg | Explanation -> 3rd argument
    # 
    prog_une=$1
    prog_deux=$2
    comment=$3

    echo -e "${IGreen}Παρακαλώ επιλέξτε ένα από τα επόμενα διαθέσιμα προγράμματα : \n"
    echo -e "'1'  για  $prog_une  $comment \n"
    echo -e "'2'  για  $prog_deux  $comment\n"
    
    read -p "Γράψτε την επιλογή σας [1, 2 ή exit] >>> " choice

    if [[ $choice =~ [1-2] ]] || [[ $choice == "exit" ]]
    then
        case "$choice" in
			1)
                echo -e "${IBlue} \nΕγκατάσταση $1 $3 ... ${NC}\n"
                if pacman -S --noconfirm $prog_une
                then
                    # Sweet, installed program
                    echo -e "${IYellow} \n[ ΕΓΙΝΕ ] Εγκατάσταση $prog_une $comment ... ${NC}\n"
                    return $OK
                else
                    # Oops, failure during program installation
                    echo -e "${IRed} \n[ ΑΠΟΤΥΧΙΑ ] Εγκατάσταση $prog_une $comment ... ${NC}\n"
                    return $NOT_OK
                fi
				;;
			2)
                echo -e "${IBlue} \nΕγκατάσταση Audacious Music Player ... ${NC}\n"
                if pacman -S --noconfirm $prog_deux
                then
                    # Sweet, installed
                    echo -e "${IYellow} \n[ ΕΓΙΝΕ ] Εγκατάσταση $prog_deux $comment ...${NC}\n"
                    return $OK
                else
                    # Oops, failure during program installation
                    echo -e "${IRed} \n[ ΑΠΟΤΥΧΙΑ ] Εγκατάσταση $prog_deux $comment ...${NC}\n"
                    return $NOT_OK
                fi
                ;;
            exit)
                echo -e "${ICyan}\n Έξοδος όπως επιλέχθηκε από τον χρήστη: '${USER}' ...\n${NC}"
                return $OK
                ;;
            *)
                echo -e "${ICyan}\nΟι επιλογές σας πρέπε να είναι [1 ή 2]. Παρακαλώ προσπάθησε ξανά τώρα!\n${NC}"
                sleep 3
                clear
                install $prog_une $prog_deux $comment
                ;;
        esac
    else
        echo -e "${ICyan}\nΟι επιλογές σας ήταν [1 ή 2]. ΠΑΡΑΚΑΛΩ προσπάθησε ξανά!\n${NC}"
        sleep 3
        clear
        install $prog_une $prog_deux $comment
    fi
    return $OK
}


# Helping function in order to continue main procedure or not
#
function continue_or_not_check() {
    echo -e "${ICyan} Θα θέλατε να συνεχίσετε με την εγκατάσταση προγράμματος $1 ? :\n"
    echo -e " Πληκτρολογήστε 'y' για ΝΑΙ 'Η 'n' για ΟΧΙ :\n"      
    read -p "Γράψτε την επιλογή σας [ y | n ] >>> " continue_or_not
    if [ "$continue_or_not" == "y" ]
    then
        echo -e "${ICyan}Προχωράμε με την εγκατάσταση $1 ... ${NC}\n"
    else
        echo -e "${IRed}Έξοδος μετά από επιλογή του υπερ-χρήστη '$USER' ...${NC}\n"
        exit $OK
    fi
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
            install "clementine" "audacious" "Music Player"
            #
            # Perform a check : User wishes to continue OR NOT ??
            #
            continue_or_not_check "Πολυμέσων (Media Player) "
            # 2nd: Install A Media Player
            #
            install "vlc" "mpv" "Media Player"
            #
            # Perform a check : User wishes to continue OR NOT ??
            #
            continue_or_not_check "περιήγησης στο Διαδίκτυο (Internet Explorer) "
            # 3rd : Install a Web Browser
            #
            install "firefox" "chromium" "Web Broswer"
            #
            # Perform a check : User wishes to continue OR NOT ??
            #
            continue_or_not_check "διαχείρησης Ηλεκτρονικού ταχυδρομίου (Email Client) "
            # 4th : Install an Email Client
            #
            install "thunderbird" "evolution" "Email Client"
            #
            # Perform a check : User wishes to continue OR NOT ??
            #
            continue_or_not_check " Επεξεργασίας κειμένου (Text Editor) "
            # 5th : Install a Text/Code Editor
            #
            install "code" "atom" "Text/Code Editor"
        fi
    fi
}


#############
### MAIN ###
###########

# Start main function
#
main