-- run the following line in the terminal
-- psql -U freecodecamp -d postgres -f ./setup.sql

-- connect to postgres
\c postgres;

-- clean database to rerun the script
DROP DATABASE IF EXISTS number_guess;

-- create database
CREATE DATABASE number_guess;

-- connect to number_guess
\c number_guess;

-- add user
CREATE TABLE users(
  user_id SERIAL PRIMARY KEY,
  username VARCHAR(22) NOT NULL,
  games_played INT DEFAULT 0,
  best_game INT DEFAULT 0
);
