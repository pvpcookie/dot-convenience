#!/bin/bash

############################################################
# CONST CONFIGS                                            #
############################################################

MAGENTO_HOST=https://repo.magento.com/packages.json

############################################################
# STYLE CONFIGS                                            #
############################################################

bold=$(tput bold)
normal=$(tput sgr0)

############################################################
# FUNCTIONS                                                #
############################################################

helpFunction()
{
   echo ""
   echo "Usage: $0 -validate -upgrade"
   echo -e "\t[-validate] Validate magneto keys"
   echo -e "\t[-upgrade] Attempt to upgrade Magento 2 Dotdigital connector"
   exit 1 # Exit script after printing help
}


print_line(){
  print_type=$2
  current_task_message=$1

  #reset message = 1
  if [ "$print_type" = "1" ]; then
    tput rc; tput ed;
    printf "############################ \r\n"
    printf "$bold Dot convenience: Magento 2  $normal \r\n"
    printf "############################ \r\n"
    printf "\r\n"
    echo "$bold $current_task_message $normal"
    return
  fi;

  #Validation message = 2
  if [ "$print_type" = "2" ]; then
      tput rc; tput ed;
      printf "$bold Dot convenience: Magento 2 Update Helper \r\n $normal"
      printf "\r\n"
      echo "ERROR: $current_task_message"
      return 0
    fi;

  if [ "$print_type" = "3" ]; then
    echo " * $current_task_message"
    return 0
  fi;

  if [ "$print_type" = "4" ]; then
      echo "$bold $current_task_message $normal"
      return 0
    fi;

  echo " - $current_task_message"
}

continue_pause(){
  while true; do
      printf "\n\r"
      read -p "Do you wish to continue? " yn
      case $yn in
          [Yy]* ) return;;
          [Nn]* ) exit;;
          * ) echo "Please answer yes or no.";;
      esac
  done
}

check_magento_token() {
  magento_username=$1
  magento_password=$2
  magento_request="curl -s -u $magento_username:$magento_password $MAGENTO_HOST"
  magento_response=$($magento_request | grep -o '"warning":"[^"]*' | grep -o '[^"]*$');
  if ! [ "$magento_response" ]; then
    print_line "$bold Magetno Keys:$normal OK"
  fi;

  if [ "$magento_response" ]; then
      print_line "$bold Response:$normal $magento_response"
  fi;
}

############################################################
# SCRIPTS                                                  #
############################################################

Check_php_exists="which php"
Check_composer_exists="which composer"
Get_magento_username="composer config http-basic.repo.magento.com.username --global"
Get_magento_password="composer config http-basic.repo.magento.com.password --global"
Get_php_version="php -v | head -n 1 |grep -Eo '[+-]?[0-9]+([.][0-9]+)'";

############################################################
# Validate                                                 #
############################################################
validate(){

  if ! [ $($Check_php_exists) ]; then
      print_line "$bold Checking PHP:$normal FAILED" 2
      print_line "$bold ERROR$normal We could not find a valid version of PHP please, insure you have php installed"
      exit 0
  fi;
  print_line "$bold Checking PHP:$normal OK"

  if ! [ $($Check_composer_exists) ]; then
      print_line "$bold Checking PHP:$normal FAILED" 2
      print_line "$bold ERROR$normal We could not find a valid version of PHP please, insure you have php installed"
      exit 0
  fi;
  print_line "$bold Composer:$normal OK"

  check_magento_token $($Get_magento_username) $($Get_magento_password)
}
############################################################
# RUN                                                      #
############################################################

while getopts "v:u:h" opt
do
   case "$opt" in
      v ) validate; exit 0 ;;
      u ) exit 0 ;;
      h ) helpFunction ;;
   esac
done

while true; do

    print_line "Please select a task from the list below." 1
    printf "\r\n"
    print_line "1) Run validation" 3
    print_line "2) Upgrade Magento" 3
    print_line "3) Exit" 3
    printf "\r\n"
    read -p "task? " yn

    case $yn in
        [1]* )
          print_line "Running Validation" 1
          validate;
          continue_pause
          continue;
        break;;
        [2]* ) continue;;
        [3]* ) exit 0;;
        * ) echo "Please use one of the above options";;
    esac
done


