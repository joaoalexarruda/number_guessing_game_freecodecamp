#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

# counter of number of guesses
counter=0

GET_GUESS() {
  read USER_GUESS
  ((counter++))
  # if user guess is not integer nor between 1 and 1000
  if [[ ! "$USER_GUESS" =~ ^([1-9][0-9]{0,2}|1000)$ ]]
  then
    echo "That is not an integer, guess again:"
    GET_GUESS
  else
    # if it's higher than gen number
    if [[ $USER_GUESS > $GEN_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      GET_GUESS
    # if its lower than gen number
    elif [[ $USER_GUESS < $GEN_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      GET_GUESS
    # if it's equal
    else
      echo -e "\nYou guessed it in $counter tries. The secret number was $GEN_NUMBER. Nice job!"
      # Update the games_played for the user
      UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME';")
      # get best game from existing user
      BEST_GAME_QUERY=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME';")
      BEST_GAME=$(echo $BEST_GAME_QUERY | sed 's/^ *//;s/ *$//')
      if [[ $BEST_GAME_QUERY -lt $counter ]]
      then
        # update best_game for the user
        UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $counter WHERE username = '$USERNAME';")
      fi
    fi
  fi
}


MAIN() {
  # generate number
  GEN_NUMBER=$((( RANDOM % 1000 ) + 1 ))
  # get username
  echo "Enter your username:"
  read USERNAME
  # search username in database
  USERNAME_QUERY=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME';")
  # if not found
  if [[ -z $USERNAME_QUERY ]]
  then
    # welcome user and add to database
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    USERNAME_INSERT=$($PSQL "INSERT INTO users(username) values('$USERNAME');")
  else
    # welcome back existing user
    GET_GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME';")
    GET_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME';")
    GAMES_PLAYED=$(echo $GET_GAMES_PLAYED | sed 's/^ *//;s/ *$//')
    BEST_GAME=$(echo $GET_BEST_GAME | sed 's/^ *//;s/ *$//')
    echo "Welcome back, $USERNAME! You have played $GET_GAMES_PLAYED games, and your best game took $GET_BEST_GAME guesses."
  fi
  # read user number guess
  echo "Guess the secret number between 1 and 1000:"
  GET_GUESS
}


MAIN