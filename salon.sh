#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi
  echo -e "\n--- Benvenuto al salon! Scegli un servizio tra quelli elencati qui sotto: ---\n"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  if [[ -z $SERVICES ]]; then
    echo -e "\nNon ci sono servizi disponibili in questo momento."
  else
    echo "$SERVICES" | while read SERVICE_ID BAR NAME; do
      echo "$SERVICE_ID) $NAME"
    done
  fi
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; 
then
  MAIN_MENU "Questa opzione non é valida"
else
  SERVICE_AVAILABILITY=$($PSQL "SELECT * FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_AVAILABILITY ]]; then
    # Send to main menu
    MAIN_MENU "Questo servizio non é disponibile"
  else
    # get customer info
    echo -e "\nIl tuo numero di telefono?"
    read CUSTOMER_PHONE
    
    #check if the user exists in the database
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    #if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      #get new customer name
      echo -e "\nCome ti chiami?"
      read CUSTOMER_NAME

      #insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    #get the customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #get the appointment time
    echo -e "\nA che ora desideri prenotare l'appuntamento?"
    read SERVICE_TIME

    #insert the record in the appointments table
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) values('$CUSTOMER_ID','$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
    if [[ -z $INSERT_APPOINTMENT_RESULT ]]
    then
    MAIN_MENU "Non é stato possibile prenotare l'appuntamento."
    else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
fi
}

MAIN_MENU


