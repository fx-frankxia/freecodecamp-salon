#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t -c"
echo -e "\n~~~~~ Welcome to Salon ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo "How may I help you?"
  echo "Please choice a service:"
  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICE_LIST" | sed 's/|/ /g' | while read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  IF_SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED" | sed 's/^ *//g')
  if [[ -z $IF_SERVICE_ID_SELECTED ]]
  then
    MAIN_MENU "This is a valid service number"
  else
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | sed 's/^ *//g')
    echo -e "\nYou have choiced $SERVICE_ID_SELECTED) $SERVICE_NAME_SELECTED" 
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
    then
      # INSERT NEW CUSTOMER
      echo -e "\nOh~~ You are our new customer!"
      echo "What is your name?"
      read CUSTOMER_NAME
      RESULT_INSERT_A_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo "Thank you '$CUSTOMER_NAME', your information is recorded"
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID" | sed 's/^ *//g')
    fi
    # INSERT APPOINTMENT
    echo -e "\nWhat time would you like to book for your service?"
    read SERVICE_TIME
    RESULT_INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo "service id is $SERVICE_ID_SELECTED"
    echo "customer phone is $CUSTOMER_PHONE"
    echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."    
  fi
}

MAIN_MENU