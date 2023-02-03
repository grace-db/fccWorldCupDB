#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# get team_id
function GET_TEAM_ID() {
  echo "$($PSQL "SELECT team_id FROM teams WHERE name='$*'")"
}

# function re-usable for setting winner_id & opponent_id, since they align with primary keys of team_id
function INSERT_TEAM() {
  TEAM="$*"
  # set team_id
  TEAM_ID=$(GET_TEAM_ID "$TEAM")

  # if not found
  if [[ -z $TEAM_ID ]]
  then
    # insert team
    INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$TEAM')")
    if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
    then
      # get new team_id
      TEAM_ID=$(GET_TEAM_ID "$TEAM")
    else
      # returns null
      return 1
    fi
  fi
  echo $TEAM_ID
}

echo $($PSQL "TRUNCATE TABLE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WIN_G OP_G
do
  # skip first row
  if [[ $YEAR == year ]]
  then
    continue
  fi

  # get winner
  WINNER_ID=$(INSERT_TEAM "$WINNER")

  # get opponent
  OPPONENT_ID=$(INSERT_TEAM "$OPPONENT")

  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WIN_G, $OP_G)")
  if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
  then
    echo "Inserted into game, $YEAR $ROUND: $WINNER VS. $OPPONENT :: $WIN_G - $OP_G"
  fi
done
