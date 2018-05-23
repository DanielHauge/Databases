# Databases
This repository is for database things in a project for Software development (PBA) in Test and Database course.

This part (database) is based on a project description which can be found [Here](https://github.com/datsoftlyngby/soft2018spring-databases-teaching-material/blob/master/assignments/Project%20Description.ipynb)

## Introduction
- About what this project sets out to do. and some introduction stuff.


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

This .csv file has been obtained from a program we've build to capture and store relevant data from many books (.txt) files. The program can be found in this repository [BookParser](https://github.com/soft2018spring-gruppe10/Databases/blob/master/BookParser/src/Main.main/java/Main.main.java).

It should also be noted, that we have removed all qoutes from title and authors, and set author and title to Unknown if we could not scrape anything nor find corresponding RDF file. Also we have changed coma's in titles and authors to middle dot. We have done this intetional. It is also known that the user will need to input the right middle dot to actully get to search for it, but with this in mind we will implement auto completion to help user with this exact inconvinience.

Also, because of time constraints. We only support multiple authors as a single entity. ie. Books will contain 1 author, but might represent more authors. eg. "Isaac newton & Charles darwin". An additional consequence of not supprting multiple authors 100% is that if 2 authors has written a book on their own, but also colaborated on a book together, they will be registered as 3 unique authors: eg. "Isaac Newton", "Charles darwin" and "Isaac Newton & Charles darwin". Idealy we would have wanted another csv file with authors and also which books they wrote and so fourth. This would allow for many authors to have written a single book and so on. ie. Supporting multiple authors alot better. 

#### [BookMentions.csv](https://github.com/soft2018spring-gruppe10/Databases/blob/master/TestMentions.csv)
bookid | cityid | amount
:-----:|:-------:|:----------:
integer of bookid | integer of cityid | amount of occurences in integer

This .csv file has been obtained from a program we've build to capture and store relevant data from many books (.txt) files, by also corssreferencing from all the cities in "Cities csv file". The potential cities has been captured by stanfords named entity recognition software. The program can be found in this repository [BookParser](https://github.com/soft2018spring-gruppe10/Databases/blob/master/BookParser/src/Main.main/java/Main.main.java).

## DBMS

### Key-Value store (Redis)
##### Init
To get our redis instance up and running with importet data. Run these commands in any linux distribution with docker installed. Import script: [Here](https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/DBScripts/RedisUp.sh)
```
wget https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/DBScripts/RedisUp.sh
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
allbooks | ["bookid1_booktitle1", "bookid2_booktitle2", ... ] | SMEMBERS
allcities | ["cityid1_cityname1" ,"cityid2_cityname2", ... ] | SMEMBERS
M_book-city:\<bookid\> | [cityid1_count, cityid2_count, ... ] | SMEMBERS
M_city-book:\<cityid\> | [bookid1_count, bookid2_count, ... ] | SMEMBERS
geospartial | [cityid1, cityid2, ... ] | GEORADIUSBYMEMBERS

##### Documentation & Query
Query: [RedisDataAcesser](https://github.com/soft2018spring-gruppe10/Backend/blob/master/DBParadigmsGroup10/src/main/java/DataAcessors/RedisDataAcessor.java)
Documentation & Reflection: [KVDocumentation](https://github.com/soft2018spring-gruppe10/Databases/blob/master/Documentation/KVDocumentation.md)

### Document Oriented (MongoDB)

##### Init
To get our mongodb instance up and running with imported data. Run these commands in any linux distribution with docker installed. Import script: [Here](https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/DBScripts/MongUp.bash).
```
wget -O - https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/DBScripts/MongUp.bash | bash
```
##### Structure
The structure of this mongo database is pretty much the same as the the csv files. ie. each line in the csv files correspond to a document. Each csv file has its own collection. cities, books, mentions are the collections each document is under.

- cities
```
{ "_id" : ObjectId("5b01faf312b0434890db7f4d"), "Cityid" : 3039678, "Name" : "Ordino", "Latitude" : 42.55623, "Longitude" : 1.53319, "cc" : "AD", "Population" : 3066 }
```
- books
```
{ "_id" : ObjectId("5b01faf412b0434890dc3c7a"), "Bookid" : 1, "Title" : "The Declaration of Independence", "Author" : "Jefferson· Thomas" }
```
- mentions
``` 
{ "_id" : ObjectId("5b01faf412b0434890dcce1b"), "Bookid" : 2, "Cityid" : 1710116, "Amount" : 186 }
```

##### Documentation & Query
Query: [MongoDataAccessor](https://github.com/soft2018spring-gruppe10/Backend/blob/master/DBParadigmsGroup10/src/main/java/DataAcessors/MongoDataAcessor.java)
Documentation & Reflection: [MongoDB Documentation](https://github.com/soft2018spring-gruppe10/Databases/blob/master/Documentation/DO-Documentation.md)

### Relational (Postgres sql)
##### Init
To get our postgres sql instance up and running with importet data. Run this command in any linux distribution with docker installed. This init script below will initialize and import the data. [Init&Import script](https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/DBScripts/PostGressqlUp.sh)
```
wget -O - https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/DBScripts/PostGressqlUp.sh | bash
```

##### Structure
![](https://cdn.discordapp.com/attachments/439727300137975818/443745533979262976/Postgres_ERD.png)


- Book

| Column | Type              |
|--------|-------------------|
| id     | integer           |
| title  | character varying |
| author | character varying |

```
Indexes:
    "books_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "mentions" CONSTRAINT "mentions_bookid_fkey" FOREIGN KEY (bookid) REFERENCES books(id)
```

- Cities

| Column     | Type              |
|------------|-------------------|
| id         | integer           |
| name       | character varying |
| latitude   | double precision  |
| longitude  | double precision  |
| cc         | character varying |
| population | integer           |

```
Indexes:
    "cities_pkey" PRIMARY KEY, btree (id)
    "cities_name_index" btree (name)
Referenced by:
    TABLE "mentions" CONSTRAINT "mentions_cityid_fkey" FOREIGN KEY (cityid) REFERENCES cities(id)
```

- Mentions

| Column | Type    |
|--------|---------|
| bookid | integer |
| cityid | integer |
| amount | integer |

```
Foreign-key constraints:
    "mentions_bookid_fkey" FOREIGN KEY (bookid) REFERENCES books(id)
    "mentions_cityid_fkey" FOREIGN KEY (cityid) REFERENCES cities(id)
```

##### Documentation & Query
Query: [PostgresDataAccessor](https://github.com/soft2018spring-gruppe10/Backend/blob/master/DBParadigmsGroup10/src/main/java/DataAcessors/PostgresDataAcessor.java)
Documentation & Reflection: [Postgres Documentation](https://github.com/soft2018spring-gruppe10/Databases/blob/master/Documentation/Postgres%20Documentation.ipynb)

### Graph (Neo4j)
##### Init
To get our neo4j instance up and running with importet data. Run this command in any linux distribution with docker installed. This init script will initialize and import data to a instance of neo4j. Script [here](https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/DBScripts/Neo4jUp.sh) To setup, and import the rest: [Import](https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/DBScripts/Neo4jImport.sh)
```
wget -O - https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/DBScripts/Neo4jUp.sh | bash
```
To import data, also do this command when it is done.
```
./Neo4jImport.sh
```
To optimize the database after the data has been imported this command can be used:
```
sudo docker exec -it neo4j sh -c 'cat /root/OptimNeo4j.cypher | bin/cypher-shell --format plain'
```


##### Structure
[![https://gyazo.com/28b62f84039947ac53d8657e52f0af53](https://i.gyazo.com/28b62f84039947ac53d8657e52f0af53.png)](https://gyazo.com/28b62f84039947ac53d8657e52f0af53)

- Node:book contains title and author
- Edge:mention contains amount
- node:city contains cc, name, latitude, longitude and population


##### Documentation & Query
Query: [Neo4jDataAcesser](https://github.com/soft2018spring-gruppe10/Backend/blob/master/DBParadigmsGroup10/src/main/java/DataAcessors/Neo4jDataAcessor.java)
Documentation & Reflection: [Neo4j Documentation](https://github.com/soft2018spring-gruppe10/Databases/blob/master/Documentation/Neo4jDocumentation.md)

## Results

### Unoptimized benchmark

See [neo4j.unoptimized](https://gist.github.com/DanielHauge/a589a3761677e40dbfb66d873ec5b8f1), [postgres.unoptimized](https://gist.github.com/Retroperspect/c2dd41234a5e4be444eff9093506fa41), [redis.unoptimized](https://gist.github.com/DanielHauge/2fece941ad71ac1715d7497068194d72), [mongo.unoptimized](https://gist.github.com/DanielHauge/578bf358e7433616dd88694641e6a0b5)

Query | Average Redis | Median Redis | Average Mongo | Median Mongo | Average Postgres | Median Postgres | Average Neo4j | Median Neo4j
-----:|:-------:|:---------:|:-------:|:---------:|:---------:|:---------:|:---------:|:---------
getBooksByCity | 909ms | 627ms | 37572ms | 25898ms | 144ms | 113ms | 131ms | 76ms
getCityBybook | 5ms | 5ms | 743ms | 767ms | 76ms | 76ms | 73ms | 82ms
getAllCities | 44ms | 40ms | 245ms | 255ms | 46ms | 45ms | 201ms | 209ms
getAllBooks | 47ms | 40ms | 98ms | 84ms | 48ms | 45ms | 222ms | 235ms
getBookByAuthor | 4ms | 1ms | 19ms | 18ms | 4ms | 5ms | 33ms | 33ms
getBooksInVicenety1 | 2048ms | 1591ms | N/A | N/A | 1142ms | 881ms | 4795ms | 4613ms
getBooksInVicenety2 | 1511ms | 410ms | N/A | N/A | 1114ms | 827ms | 1438ms | 1260ms
getBooksInVicenety3 | 1466ms | 307ms | N/A | N/A | 1098ms | 825ms | 746ms | 525ms
getAllAuthors | 10ms | 10ms | 101ms | 103ms | 19ms | 19ms | 125ms | 124ms
getCitiesBybook | 4ms | 5ms | 745ms | 795ms | 75ms | 75ms | 21ms | 20ms

### Optimized benchmark
See [neo4j.optimized](), [postgres.optimzed](https://gist.github.com/Retroperspect/a552b9b11e41e3cce8e3bc466cf3da51), [redis.optimized](), [Mongo.optimized](https://gist.github.com/DanielHauge/2fb10e157b2616681d449923230e0949)

Query | Average Redis | Median Redis | Average Mongo | Median Mongo | Average Postgres | Median Postgres | Average Neo4j | Median Neo4j
-----:|:-------:|:---------:|:-------:|:---------:|:---------:|:---------:|:---------:|:---------
getBooksByCity | x | x | 203ms | 130ms | 125ms | 108ms | x | x
getCityBybook | x | x | 7ms | 4ms | 67ms | 66ms | x | x
getAllCities | x | x | 252ms | 244ms | 47ms | 46ms | x | x
getAllBooks | x | x | 117ms | 121ms | 50ms | 44ms | x | x
getBookByAuthor | x | x | 3ms | 2ms | 4ms | 4ms | x | x
getBooksInVicenety1 | x | x | x | x | 426ms | 160ms | x | x
getBooksInVicenety2 | x | x | x | x | 403ms | 107ms | x | x
getBooksInVicenety3 | x | x | x | x | 387ms | 104ms | x | x
getAllAuthors | x | x | 111ms | 107ms | 19ms | 19ms | x | x
getCitiesBybook | x | x | 7ms | 4ms | 68ms | 68ms | x | x

## Conclusion and Discussion
