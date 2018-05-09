# Databases
This repository is for database things in a project for Software development (PBA) in Test and Database course.

## Data

#### [CitiesFinal.csv](https://github.com/soft2018spring-gruppe10/Databases/blob/master/TestCities.csv)
id  | asciiname | latitude | longitude | cc | population
:-----:|:---------|:-------:|:---------:|:------:|:-----:
integer |  name of city in ascii | latitude in double/float | longitude in double/float | country code as 2 letters | population in integer

This .csv file has been obtained from: http://download.geonames.org/export/dump/.

Version cities5000.csv. The data has been heavily refractored to make it easier to work with. Delimiter has been changed from tab to coma, and a few colomns has been removed because they were not usefull for us.

#### [Books.csv](https://github.com/soft2018spring-gruppe10/Databases/blob/master/TestBooks.csv)
id | title | author 
:-----:|:-------:|:--------:
integer | title of book | author of book

This .csv file has been obtained from a program we've build to capture and store relevant data from many books (.txt) files. The program can be found in this repository [BookParser](https://github.com/soft2018spring-gruppe10/Databases/blob/master/BookParser/src/main/java/main.java).

It should also be noted, that we have removed all qoutes from title and authors, and set author and title to Unknown if we could not scrape anything. Also we have changed coma's in titles and authors to middle dot. We have done this intetional. It is also known that the user will need to input the right middle dot to actully get to search for it, but with this in mind we will implement auto completion to help user with this.

#### [BookMentions.csv](https://github.com/soft2018spring-gruppe10/Databases/blob/master/TestMentions.csv)
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

##### Protocol & Query
Query: [RedisDataAcesser]()
Protocol: [KVDocumentation]()

### Document Oriented (MongoDB)

##### Init
In porgress.
##### Structure
In porgress.

##### Protocol & Query
Query: [MongoDataAccessor]()
Protocol: [MongoDB Documentation]()

### Relational (Postgres sql)
##### Init
To get our postgres sql instance up and running with importet data. Run this command in any linux distribution with docker installed.
```
wget -O - https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/PostGressqlUp.bash | bash
```

##### Structure

- Book

| Column | Type              |
|--------|-------------------|
| id     | integer           |
| title  | character varying |
| author | character varying |

Indexes:
    "books_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "mentions" CONSTRAINT "mentions_bookid_fkey" FOREIGN KEY (bookid) REFERENCES books(id)

- Cities

| Column     | Type              |
|------------|-------------------|
| id         | integer           |
| name       | character varying |
| latitude   | double precision  |
| longitude  | double precision  |
| cc         | character varying |
| population | integer           |

Indexes:
    "cities_pkey" PRIMARY KEY, btree (id)
    "cities_name_index" btree (name)
Referenced by:
    TABLE "mentions" CONSTRAINT "mentions_cityid_fkey" FOREIGN KEY (cityid) REFERENCES cities(id)

- Mentions

| Column | Type    |
|--------|---------|
| bookid | integer |
| cityid | integer |
| amount | integer |

Foreign-key constraints:
    "mentions_bookid_fkey" FOREIGN KEY (bookid) REFERENCES books(id)
    "mentions_cityid_fkey" FOREIGN KEY (cityid) REFERENCES cities(id)

##### Protocol & Query
Query: [PostgresDataAccessor]()
Protocol: [Postgres Documentation]()

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
[![https://gyazo.com/28b62f84039947ac53d8657e52f0af53](https://i.gyazo.com/28b62f84039947ac53d8657e52f0af53.png)](https://gyazo.com/28b62f84039947ac53d8657e52f0af53)

- Node:book contains title and author
- Edge:mention contains amount
- node:city contains cc, name, latitude, longitude and population


##### Protocol & Query
Query: [Neo4jDataAcesser]()
Protocol: [Neo4j Documentation]()
