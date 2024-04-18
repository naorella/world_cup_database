#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
#empty tables if, incase data is present from previous test
echo $($PSQL "TRUNCATE games, teams")

#Read CSV headers as columns and we repeat through CSV until empty
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != "winner" ]]
  then
    ALREADY_IN_WIN=$($PSQL "SELECT name FROM teams WHERE name = '$WINNER'")
    ALREADY_IN_OPP=$($PSQL "SELECT name FROM teams WHERE name = '$OPPONENT'")

    #check if winners already exist
    if [[ -z $ALREADY_IN_WIN ]]
    then
      #insert the winnning team into names if deosn't
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      #return result
      if [[ $INSERT_TEAM == 'INSERT 0 1' ]]
      then
        echo "Inserted: $WINNER"
      fi
    #check if opponenets are in
    elif [[ -z  $ALREADY_IN_OPP ]]
    then
      #insert in opponenets if they don't exist
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      #return result
      if [[ $INSERT_TEAM == 'INSERT 0 1' ]]
      then
        echo "Inserted: $WINNER"
      fi
    fi
  fi
done

#loop through list again
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then
    #Find the ids for the winning and opponent team
    WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    #Insert the data into the table
    INSERT_GAME="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WIN_ID, $OPP_ID, $WINNER_GOALS, $OPPONENT_GOALS)")"
    #return the result to terminal
    if [[ $INSERT_GAME == 'INSERT 0 1' ]]
    then
      echo -e "INSERTED GAME: $ROUND $WINNER vs $OPPONENT\n$WINNER_GOALS to $OPPONENT_GOALS"
    fi
  fi
done