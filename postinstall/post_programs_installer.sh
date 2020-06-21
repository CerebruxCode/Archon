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


# Exit codes για success || failure
#
# setfont gr928a-8x16.psfu
OK=0
NOT_OK=1

# A few colors
#
IRed='\033[0;91m'         # Red
#IGreen='\033[0;92m'       # Green
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
    else
        echo -e "${IRed} Η σύνδεση στο Διαδίκτυο φαίνεται απενεργοποιημένη ... Ματαίωση ...\n"
        echo -e "Συνδεθείτε στο Διαδίκτυο και δοκιμάστε ξανά ... \n Ματαίωση...${NC}"
        exit $NOT_OK
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
    comment="$3 $4"

    PS3="Γράψτε την επιλογή σας [1 -> $prog_une, 2 -> $prog_deux ή 3 -> exit] >>> "
    options=("$prog_une" "$prog_deux" "exit")

    select choice in "${options[@]}"
    do

        case "$choice" in
			"$prog_une")
                echo -e "${IBlue} \nΕγκατάσταση $1 $3 ... ${NC}\n"
                if pacman -S --noconfirm "$prog_une"
                then
                    # Sweet, installed program
                    echo -e "${IYellow} \n[ ΕΠΙΤΥΧΗΣ ] Εγκατάσταση $prog_une $comment ... ${NC}\n"
                    return $OK
                else
                    # Oops, failure during program installation
                    echo -e "${IRed} \n[ ΑΠΟΤΥΧΙΑ ] Εγκατάσταση $prog_une $comment ... ${NC}\n"
                    return $NOT_OK
                fi
				;;
			"$prog_deux")
                echo -e "${IBlue} \nΕγκατάσταση Audacious Music Player ... ${NC}\n"
                if pacman -S --noconfirm "$prog_deux"
                then
                    # Sweet, installed
                    echo -e "${IYellow} \n[ ΕΠΙΤΥΧΗΣ ] Εγκατάσταση $prog_deux $comment ...${NC}\n"
                    return $OK
                else
                    # Oops, failure during program installation
                    echo -e "${IRed} \n[ ΑΠΟΤΥΧΙΑ ] Εγκατάσταση $prog_deux $comment ...${NC}\n"
                    return $NOT_OK
                fi
                ;;
            "exit")
                echo -e "${ICyan}\n Έξοδος όπως επιλέχθηκε από τον χρήστη: '${USER}' ...\n${NC}"
                return $OK
                ;;
            *)
                echo -e "${ICyan}\nΟι επιλογές σας πρέπει να είναι [1 ή 2 ή 3]. Μη έγκυρη επιλογή! \n\n${NC}"
                sleep 1
                ;;
        esac

    done

    return $OK
}


# Helping function in order to continue main procedure or not
#
function continue_or_not_check() {
    echo -e "Θα θέλατε να συνεχίσετε με την εγκατάσταση προγράμματος $1 ?\n"

    PS3="Γράψτε την επιλογή σας [1 -> Yes | 2 -> No] >>> "
    options=("yes" "no")

    select continue_or_not in "${options[@]}"
    do
        case "$continue_or_not" in
            "yes")
                echo -e "${ICyan}Προχωράμε με την εγκατάσταση $1 ... ${NC}\n"
                break
                ;;
            "no")
                echo -e "${IRed}Έξοδος μετά από επιλογή του υπερ-χρήστη '$USER' ...${NC}\n"
                exit $OK
                ;;
            *)
                echo -e "${ICyan}Invalid option detected ...\n${NC}"
                ;;
        esac
    done
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
        #
        # Perform a check : User wishes to continue OR NOT ??
        #
        continue_or_not_check " Εξυπηρετητή Torrent (BitTorrent Client) "
        # 6th : Install a Bit Torrent Client
        #
        install "transmission-gtk" "deluge" # "ktorrent" "rtorrent" ??

    fi
}


#############
### MAIN ###
###########

# Start main function
#
main

echo -e " $IBlue '$(basename "$0")' Ολοκληρώθηκε με επιτυχία ... $NC \n"

# TODO: Add logging of all actions maybe ???
#

