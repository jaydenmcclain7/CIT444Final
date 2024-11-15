CIT444FinalGUI.zip is my GUI in a eclipse project.

This zip includes JavaFX for the GUI using a Vbox display. I used a task to load the data from the database in the background.

CategoryRatings.py is my sentiment analysis script in PyCharm.

This script runs analysis on each review giving it a rating in each category and prints REVIEWID, HOTELID, SERVICE, PRICE, ROOM, LOCATION. The script also searches
through my chunked up processed reviews and continuely adds the results of each file to the CSV.

HotelInsertion.sql is my script to read the hotels CSV file and insert them into the database using PL/SQL

ProcessedReviews.SQL is my script to take the one large CSV file and chunk it up for easier processing.

RatingsInsertions.sql is my script for reading the ratings csv produced by CategoryRatings.py

This inserts the results of this CSV into the ratings table for all of the reviews. it also takes the average ratings for each catergory for each hotel and creates
a new table storing this. The new table will only have one row for each hotel and have the already averaged hotel categories.

WordDictionary.py is a script that gives me a frequency dictionary for the words used in the reviews.
