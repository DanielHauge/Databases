# Databases
This repository is for database things in a project for Software development (PBA) in Test and Database course.

This part (database) is based on a project description which can be found [Here](https://github.com/datsoftlyngby/soft2018spring-databases-teaching-material/blob/master/assignments/Project%20Description.ipynb)

## Introduction
This projects goal is to build an application that queries different databases from different database paradigms, with the end goal of giving a recommendation for a DBMS from one of the database paradgims.


### Initial Problem statement
Which database paradigm is best?

Given end-userqueries found in [Project description](https://github.com/datsoftlyngby/soft2018spring-databases-teaching-material/blob/master/assignments/Project%20Description.ipynb), which database management system form the 4 database paradigm is best at the given task?, but also in general?

Considering what is best requires some parameters. Given the parameters: 
- Speed
- Ease of use
- Future Proof
- Compability

### Hypothesis
We expect graph based databases to be less fast than other databases (particularly sql based). Reasoning is from our own experience we gathered <sup>[1]</sup>. We also expect sql to be very easy to use and compatible with most languages, but less future proof than other dbms in terms of flexibility. We expect key-value store to be very fast at simple queries and tasks, but lack behind when it comes to aggregations and bigger or more complex queries. We don't realy have a good impression and lack knowledge and experience with document oriented databases to expect anything in particular. 

We expect to experience that databases varies in all catergories. That each paradigm come with it's highlights and challenges in all areas. Which makes us expect we have to recommend a database system depending on alot of factors, depending on how requirements fit a given paradigms strengh or it's weakness.

### Plan
To put the hypothesis to the grind stone, we will download all the books from the guttenberg project with the [download script](https://github.com/datsoftlyngby/soft2018spring-databases-teaching-material/tree/master/book_download) from the project description, in a vagrant virtual machine. And the RDF meta data files aswell. Build a Bookparser application that can parse the books, and generate csv files for books and use the stanfords entity recognizer to find potential city mentions and therafter crossreference them with data from http://geonames.org. Citydata from geonames. Books and mention data parsed from many book files (.txt and .rdf) from guttenberg. This will be the foundation for the data we will use in the databases. 

We will construct 4 scripts to initialize a database from each paradigm, import the data and optimize with indexes and such.
We will build an API that can interact and switch database. This API will do the end-user queries. We will implement a benchmark test to be able to extract some information about speed of the databases, but also implement a logging systme, to get a more hands-on feel for how fast it is going. While we also take notice of things such as: how easy it was to implement an interface for the database, how compatible the database is with the queries and also how easy a refractoring or database migration would be.

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

## Data Model in Application
We have moddeled our data with the perspective from the frontend. In other words, we thought: What do we want to display and how? and then modelled after datamodel after that. We decided on vue.js as the frontend framework which realy likes json, so we decided on json as the API endpoint wireformat. The Api endpoint documentation can be found [here](https://github.com/soft2018spring-gruppe10/Backend/blob/master/API_PROTOCOL.md), here all routes and data models that the frontned would like is documented. We then modelled the datamodels from this. There is alot of different formats which the data gets transfered to the frontend, hence we implemented an interface of a dataobject which extends(inherets) gson that can parse objects into json. So we have a implementation of the dataobject for each format we want to give the frontend. All the different data models can be found in the [DataObjects Folder](https://github.com/soft2018spring-gruppe10/Backend/tree/master/DBParadigmsGroup10/src/main/java/DataObjects) in our [backend repository](https://github.com/soft2018spring-gruppe10/Backend).

Example:
```java
public class CityByBook extends DataSerializer implements DataObject {
    private final int bookId;
    private final String bookTitle;
    public final CityWithCords[] cities;

    public CityByBook(int id, String title, CityWithCords[] cits){
        this.bookId = id;
        this.bookTitle = title;
        this.cities = cits;
    }
}
```
```java
public class CityWithCords extends DataSerializer implements DataObject {
    public final String cityName;
    public final double lat;
    public final double lng;

    public CityWithCords(String name, double lat, double lon){
        this.cityName = name;
        this.lat = lat;
        this.lng = lon;
    }
}
```
Which in json translates to:
```json
{
  "bookId": 123,
  "bookTitle": "Some Title",
  "cities": [
    {
      "cityName": "Copenhagen",
      "latitude": 1.213312,
      "longitude": 1.21321
    },
    {
      "cityName": "Stockholm",
      "latitude": 1.213312,
      "longitude": 1.21321
    },
    {
      "cityName": "Amsterdam",
      "latitude": 1.213312,
      "longitude": 1.21321
    },
    {..}
  ]
}
```

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
Collections with document examples:
- cities
```
{ "_id" : ObjectId("5b0595794b6d69db6db50e9e"), "Cityid" : 2618425, "Name" : "Copenhagen", "CC" : "DK", "pop" : 1153615, "location" : { "type" : "Point", "coordinates" : [ 12.56553, 55.67594 ] } }
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

## Evaluation

### Evaluation/Benchmark setup

### Unoptimized benchmark

See [neo4j.unoptimized](https://gist.github.com/DanielHauge/a589a3761677e40dbfb66d873ec5b8f1), [postgres.unoptimized](https://gist.github.com/Retroperspect/c2dd41234a5e4be444eff9093506fa41), [redis.unoptimized](https://gist.github.com/DanielHauge/2fece941ad71ac1715d7497068194d72), [mongo.unoptimized](https://gist.github.com/DanielHauge/578bf358e7433616dd88694641e6a0b5)

Query | Average Redis | Median Redis | Average Mongo | Median Mongo | Average Postgres | Median Postgres | Average Neo4j | Median Neo4j
-----:|:-------:|:---------:|:-------:|:---------:|:---------:|:---------:|:---------:|:---------
getBooksByCity | 909ms | 627ms | 37572ms | 25898ms | 144ms | 113ms | 131ms | 76ms
getCityBybook | 5ms | 5ms | 743ms | 767ms | 76ms | 76ms | 73ms | 82ms
getAllCities | 44ms | 40ms | 245ms | 255ms | 46ms | 45ms | 201ms | 209ms
getAllBooks | 47ms | 40ms | 98ms | 84ms | 48ms | 45ms | 222ms | 235ms
getBookByAuthor | 4ms | 1ms | 19ms | 18ms | 4ms | 5ms | 33ms | 33ms
getBooksInVicenety1 (100km) | 2048ms | 1591ms | N/A | N/A | 1142ms | 881ms | 4795ms | 4613ms
getBooksInVicenety2 (50km) | 1511ms | 410ms | N/A | N/A | 1114ms | 827ms | 1438ms | 1260ms
getBooksInVicenety3 (20km) | 1466ms | 307ms | N/A | N/A | 1098ms | 825ms | 746ms | 525ms
getAllAuthors | 10ms | 10ms | 101ms | 103ms | 19ms | 19ms | 125ms | 124ms
getCitiesBybook | 4ms | 5ms | 745ms | 795ms | 75ms | 75ms | 21ms | 20ms

**Note:** MongoDB cannot query geospartial data without index. [Proof / Picture of error without index](https://i.gyazo.com/c7773dc00dcc617818e64a72d8959ebe.png)

### Optimized benchmark
See [neo4j.optimized](https://gist.github.com/Retroperspect/0f1a880ca44f932d21225dd9e5f379f4), [postgres.optimzed](https://gist.github.com/Retroperspect/a552b9b11e41e3cce8e3bc466cf3da51), [Mongo.optimized](https://gist.github.com/DanielHauge/2fb10e157b2616681d449923230e0949)

Query | Average Redis | Median Redis | Average Mongo | Median Mongo | Average Postgres | Median Postgres | Average Neo4j | Median Neo4j
-----:|:-------:|:---------:|:-------:|:---------:|:---------:|:---------:|:---------:|:---------
getBooksByCity | x | x | 203ms | 130ms | 125ms | 108ms | 71ms | 50ms
getCityBybook | x | x | 7ms | 4ms | 67ms | 66ms | 37ms | 35ms
getAllCities | x | x | 252ms | 244ms | 47ms | 46ms | 122ms | 121ms
getAllBooks | x | x | 117ms | 121ms | 50ms | 44ms | 99ms | 101ms
getBookByAuthor | x | x | 3ms | 2ms | 4ms | 4ms | 12ms | 13ms
getBooksInVicenety1 (100km) | x | x | 146ms | 114ms | 426ms | 160ms | 446ms | 121ms
getBooksInVicenety2 (50km) | x | x | 101ms | 42ms | 403ms | 107ms | 434ms | 72ms
getBooksInVicenety3 (20km) | x | x | 90ms | 31ms | 387ms | 104ms | 448ms | 74ms
getAllAuthors | x | x | 111ms | 107ms | 19ms | 19ms | 63ms | 63ms
getCitiesBybook | x | x | 7ms | 4ms | 68ms | 68ms | 17ms | 17ms

**Important Note:** mongodb doesn't have compatible driver for java to do geospartial queries in aggregation. Hence results have been gained by running a manual benchmark in robo 3T. They still use same test queries. but are manually written. Testsreults [Here]()

## Conclusion and Discussion
To make it more clear, we can infer which database is the quickest in term of runtime speed for each query:

Query | Winner | Margin
-----:|:-------:|:------
getBooksByCity | neo4j | ~50ms : Postgress
getCityBybook | redis | ~1ms : mongodb
getAllCities | redis | ~3ms : postgres
getAllBooks | redis | ~3ms : postgres
getBookByAuthor | mongo | ~1ms : postgres, redis 
getBooksInVicenety1 (100km) | mongo | ~300ms : postgres,neo4j
getBooksInVicenety2 (50km) | mongo | ~325ms : postgres,neo4j
getBooksInVicenety3 (20km) | mongo | ~350ms : postgres,neo4j
getAllAuthors | redis | ~10ms : postgres
getCitiesBybook | redis | ~2ms : mongo

Another perspective we can take is the aggregated averages.

DBMS | Average | Unbiased
-----:|:------:|:---------
Redis |  604,8ms | 248,9ms
Mongo | 103,7ms | 79ms
Postgres | 159,6ms | 76,7ms
Neo4j | 174,9ms | 86,9ms

We have 2 perspectives here. One with taking all the vicenety queries into consideration, and one where we only take one of them(20km one) into consideration (unbaised one). However we can form some idea of which database might be a prefered one if we consider speed. If we knew that we are going to make alot of geospartial vicenety queries, we can definitly see from our results that mongoDB is a good choice with our setup. However if we know that we are going to query "All books, cities, authors" Then mongoDB might not be a so good idea. In that case redis and postgress is a better option. If we know that we are going to make alot of queries based on relationships as "Mentions" then neo4j might be a better option, but maybe more if we wanted to do deeper relationship searches. If we know that were are going to query different queries equally as much and want the least amount of time overall, postgres would be a good choice followed closely by mongoDB.

These results are gathered, but our own belief is that they do not proove anything totaly. However they do indicate and estimate a reality. But the results are still influenced by alot of factors, noticably the language used<sup>[2]</sup>, 


- What does the results say?.
- What can we conclude from the benchmark.
- What have influenced the results?
- How was the data model? How well did it fit the 4 databases?, Was it biased towards any of them? 
- What could have been done to get better and more accurate results?
- Does the results reflect other peoples results in "Pro's and Cons" of each of the database paradigms?

### Recommendation
4. factors in recommendations: 
- Speed (Query runtime) 
- Ease of use(How comfy is the DBMS, is it easy to learn)
- Future proof(How usefull is it to learn this dbms, most RDBMS use same language, so its quite usefull if you want to switch to another RDMS, is the DBMS refractor friendly?)
- What application is being built? ( Each DBMS has its pro's and con's, we recommend the database that support the applications requirements the best, also which language?, is it well compatible with the language used? )

- Would it have been different if requirements also included to write to the database?



###### Footnotes
- [1]: https://github.com/DanielHauge/DBEX9
- [2]: (Java)

