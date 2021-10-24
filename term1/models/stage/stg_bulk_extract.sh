#!/bin/bash

# this shell script loads all the necessary data for you.

# Please set your credentials and base directory with the tsvs!

dir=/Users/nszoni/Desktop/repos/ceu-dataeng1/term1/data/
user=root
password=admin
database=imdb

echo "WARNING! Ideally we would store our credentials in a my.cnf file or and environmental variable used by mysql for security reasons."

# truncate db

mysql --user="$user" --password="$password" --database="$database" << EOF
set FOREIGN_KEY_CHECKS = 0;
truncate table actors;
truncate table directors;
truncate table directors_genres;
truncate table movies;
truncate table movies_genres;
truncate table movies_directors;
truncate table roles;
set FOREIGN_KEY_CHECKS = 1;
EOF

for f in "$dir"*.tsv
do
    mysql -e "LOAD DATA LOCAL INFILE '"$f"' INTO TABLE `expr "$f" | sed -r "s/.+\/(.+)\..+/\1/"` COLUMNS TERMINATED BY '\t' IGNORE 1 LINES;" --user="$user" --password="$password" --database="$database"
echo "Done: '"$f"' loaded at $(date)"
done
