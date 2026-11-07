#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  NEW_USER=true
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  NEW_USER=false
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0

while true
do
  read GUESS || exit
  NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    GUESS_NUMBER=$(( 10#$GUESS ))
    if [[ $GUESS_NUMBER -eq $SECRET_NUMBER ]]
    then
      break
    elif [[ $GUESS_NUMBER -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi
done

if [[ $NEW_USER == true ]]
then
  $PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, $NUMBER_OF_GUESSES)" > /dev/null
else
  $PSQL "UPDATE users SET games_played = games_played + 1, best_game = LEAST(best_game, $NUMBER_OF_GUESSES) WHERE username='$USERNAME'" > /dev/null
fi

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
