# Databases
This repository is for database things in a project for Software development (PBA) in Test and Database course.

## Data

#### [CitiesFinal.csv](https://github.com/soft2018spring-gruppe10/Databases/blob/master/CitiesFinal.csv)
id | name | asciiname | latitude | longitude | cc | population
:-----:|:-------:|:---------|:-------:|:---------:|:------:|:-----:
integer | name of city | name of city in ascii | latitude in double/float | longitude in double/float | country code as 2 letters | population in integer

This .csv file has been obtained from: http://download.geonames.org/export/dump/.

Version cities15000.csv. The data has been heavily refractored to make it easier to work with. Delimiter has been changed from tab to coma, and a few colomns has been removed because they were not usefull for us.

#### [Books.csv](https://github.com/soft2018spring-gruppe10/Databases/blob/master/Books.csv)
id | title | author 
:-----:|:-------:|:--------:
integer | title of book | author of book

This .csv file has been obtained from a program we've build to capture and store relevant data from many books (.txt) files. The program can be found in this repository [BookParser](https://github.com/soft2018spring-gruppe10/Databases/blob/master/BookParser/src/main/java/main.java).

#### [BookMentions.csv](https://github.com/soft2018spring-gruppe10/Databases/blob/master/BookMentions.csv)
bookid | cityid | amount
:-----:|:-------:|:----------:
integer of bookid | integer of cityid | amount of occurences in integer

This .csv file has been obtained from a program we've build to capture and store relevant data from many books (.txt) files, by also corssreferencing from all the cities in "Cities csv file". The program can be found in this repository [BookParser](https://github.com/soft2018spring-gruppe10/Databases/blob/master/BookParser/src/main/java/main.java).

## DBMS

### Key-Value store (Redis)
##### Init
To get our redis instance up and running with importet data. Run these commands in any linux distribution with docker installed.
```
wget https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/RedisUp.sh
chmod +x RedisUp.sh
./RedisUp.sh
```
##### Structure

Key | Value | denote
:-------------:|:--------------:|:---------------:
book_title:\<bookid\> | "Book title" | GET
book_author:\<bookid\> | "Book author" | GET
author-book:"\<author\>" | [bookid, bookid ... ] | SMEMBERS
allauthors | ["author1", "author2", ... ] | SMEMBERS
city_name:\<cityid\> | "City name" | GET
allcities | [[cityname:"cityname1", cityid:1] ,[cityname:"cityname2", cityid:2], ... ] | SMEMBERS
M_book-city:\<bookid\> | [cityid1, cityid2, ... ] | SMEMBERS
M_city-book:\<cityid\> | [bookid1, bookid2, ... ] | SMEMBERS
geospartial | [cityid1, cityid2, ... ] | GEORADIUSBYMEMBERS



### Docment Oriented (MongoDB)
In porgress.

### Relational (Postgres sql)
##### Init
To get our postgres sql instance up and running with importet data. Run this command in any linux distribution with docker installed.
```
wget -O - https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/PostGressqlUp.bash | bash
```

##### Structure
In progress.

### Graph (Neo4j)
##### Init
To get our neo4j instance up and running with importet data. Run this command in any linux distribution with docker installed.
```
wget -O - https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/Neo4jUp.sh | bash
```
To finish it, also do this command when it is done.
```
./Neo4jImport.sh
```

##### Structure
In progress.


## Queries
- Queries can be here.
