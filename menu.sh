#!/bin/bash

MainMenu() {
   while true; do
      clear
      echo "================================================================="
      echo "|                    Oracle All-Inclusive Tool                  |"
      echo "|             Main Menu - Select Desired Operation(s):          |"
      echo "|        <CTRL-Z Anytime to Enter Interactive CMD Prompt>       |"
      echo "-----------------------------------------------------------------"
      echo " 1)  Drop Tables"
      echo " 2)  Create Tables"
      echo " 3)  Populate Tables"
      echo " 4)  Query Tables"
      echo " 5)  CRUD Operations Menu"
      echo " E)  End/Exit"
      echo -n "Choose: "

      read CHOICE

      case "$CHOICE" in
         1)
            bash drop_tables.sh
            Pause
            ;;
         2)
            bash create_tables.sh
            Pause
            ;;
         3)
            bash populate_tables.sh
            Pause
            ;;
         4)
            bash queries.sh
            Pause
            ;;
         5)
            bash crud_operations.sh
            Pause
            ;;
         [Ee])
            echo "Exiting..."
            break
            ;;
         *)
            echo "Invalid option. Please try again."
            Pause
            ;;
      esac
   done
}

Pause() {
   read -p "Press Enter to continue..."
}

# Start the menu
MainMenu
