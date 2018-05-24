# Databases
This repository is for database things in a project for Software development (PBA) in Test and Database course.

This part (database) is based on a project description which can be found [Here](https://github.com/datsoftlyngby/soft2018spring-databases-teaching-material/blob/master/assignments/Project%20Description.ipynb)

## Introduction
The goal of This project is to build an application that queries different databases from different database paradigms, with the end goal of giving a recommendation for a DBMS from one of the database paradigms.


### Initial Problem statement
Which database paradigm is best?

Given end-user queries found in [Project description](https://github.com/datsoftlyngby/soft2018spring-databases-teaching-material/blob/master/assignments/Project%20Description.ipynb), which database management system from the 4 database paradigm is best for the given task? but also in general?

Considering what is best requires some parameters. Given the parameters: 
- Speed
- Ease of use
- Future Proof
- Compatibility

### Hypothesis
We expect graph-based databases to be less fast than other databases (particularly SQL based). The reasoning is from our own experience we gathered <sup>[1]</sup>. We also expect SQL to be very easy to use and compatible with most languages, but less future-proof than other DBMS in terms of flexibility. We expect the key-value store to be very fast at simple queries and tasks, but lack behind when it comes to aggregations and bigger or more complex queries. We don't really have a good impression and lack knowledge and experience with document-oriented databases to expect anything in particular. 

We expect to experience that databases vary in all categories. That each paradigm comes with its highlights and challenges in all areas. Which makes us expect we have to recommend a database system depending on a lot of factors, depending on how requirements fit a given paradigms strength or it's weakness.

### Plan
To put the hypothesis to the grindstone, we will download all the books from the Guttenberg project with the [download script](https://github.com/datsoftlyngby/soft2018spring-databases-teaching-material/tree/master/book_download) from the project description, in a vagrant virtual machine. And the RDF metadata files as well. Build a Bookparser application that can parse the books, and generate CSV files for books and use the Stanford entity recognizer to find potential city mentions and thereafter cross-reference them with data from http://geonames.org. City-data from geonames.org. Books and mention data parsed from many book files (.txt and .rdf) from Guttenberg. This will be the foundation for the data we will use in the databases. 

We will construct 4 scripts to initialize a database from each paradigm, import the data and optimize with indexes and such.
We will build an API that can interact and switch database. This API will do the end-user queries. We will implement a benchmark test to be able to extract some information about the speed of the databases, but also implement a logging system, to get a more hands-on feel for how fast it is going. While we also take notice of things such as: how easy it was to implement an interface for the database, how compatible the database is with the queries and also how easy a refactoring or database migration would be.

## Data

#### [CitiesFinal.csv](https://github.com/soft2018spring-gruppe10/Databases/blob/master/TestCities.csv)
id  | asciiname | latitude | longitude | cc | population
:-----:|:---------|:-------:|:---------:|:------:|:-----:
integer |  name of city in ascii | latitude in double/float | longitude in double/float | country code as 2 letters | population in integer

This .csv file has been obtained from http://download.geonames.org/export/dump/.

Version cities5000.csv. The data has been heavily refactored to make it easier to work with. Delimiter has been changed from tab to coma, and a few columns have been removed because they were not useful for us.

#### [Books.csv](https://github.com/soft2018spring-gruppe10/Databases/blob/master/TestBooks.csv)
id | title | author 
:-----:|:-------:|:--------:
integer | title of book | author of book

This .csv file has been obtained from a program we've to build to capture and store relevant data from many books (.txt) files. The program can be found in this repository [BookParser](https://github.com/soft2018spring-gruppe10/Databases/blob/master/BookParser/src/Main.main/java/Main.main.java).

It should also be noted, that we have removed all quotes from title and authors, and set author and title to Unknown if we could not scrape anything nor find corresponding RDF file. Also, we have changed coma's in titles and authors to middle dot. We have done this intentionally. It is also known that the user will need to input the right middle dot to actually get to search for it, but with this, in mind, we will implement autocompletion to help the user with this exact inconvenience.

Also, because of time constraints. We only support multiple authors as a single entity. ie. Books will contain 1 author but might represent more authors. eg. "Isaac Newton & Charles Darwin". An additional consequence of not supporting multiple authors 100% is that if 2 authors have written a book on their own, but also collaborated on a book together, they will be registered as 3 unique authors: eg. "Isaac Newton", "Charles Darwin" and "Isaac Newton & Charles Darwin". Ideally, we would have wanted another CSV file with authors and also which books they wrote and so forth. This would allow for many authors to have written a single book and so on. ie. Supporting multiple authors a lot better. 

#### [BookMentions.csv](https://github.com/soft2018spring-gruppe10/Databases/blob/master/TestMentions.csv)
bookid | cityid | amount
:-----:|:-------:|:----------:
integer of bookid | integer of cityid | amount of occurrences in integer

This .csv file has been obtained from a program we've built to capture and store relevant data from many books (.txt) files, by also cross-referencing from all the cities in "Cities CSV file". The potential cities have been captured by Stanford's named entity recognition software. The program can be found in this repository [BookParser](https://github.com/soft2018spring-gruppe10/Databases/blob/master/BookParser/src/Main.main/java/Main.main.java).

## Data Model in Application
We have modeled our data with the perspective from the frontend. In other words, we thought: What do we want to display and how? and then modeled the data model after that. We decided on vue.js as the frontend framework which really likes json, so we decided on json as the API endpoint wire format. The API endpoint documentation can be found [here](https://github.com/soft2018spring-gruppe10/Backend/blob/master/API_PROTOCOL.md), here all routes and data models that the frontend would like is documented. We then modeled the data models from this. There is a lot of different formats which the data gets transferred to the frontend, hence we implemented an interface of a data object which extends(inherits) gson that can parse objects into json. So we have an implementation of the data object for each format we want to give the frontend. All the different data models can be found in the [DataObjects Folder](https://github.com/soft2018spring-gruppe10/Backend/tree/master/DBParadigmsGroup10/src/main/java/DataObjects) in our [backend repository](https://github.com/soft2018spring-gruppe10/Backend).

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

### Relational (Postgres SQL)
##### Init
To get our Postgres SQL instance up and running with imported data. Run this command in any Linux distribution with Docker installed. This init script below will initialize and import the data. [Init&Import script](https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/DBScripts/PostGressqlUp.sh)
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
To get our neo4j instance up and running with importet data. Run this command in any Linux distribution with Docker installed. This init script will initialize and import data to an instance of neo4j. Script [here](https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/DBScripts/Neo4jUp.sh) To setup, and import the rest: [Import](https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/DBScripts/Neo4jImport.sh)
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
We will evaluate based on our implementation in our API, see [Back-end repository](https://github.com/soft2018spring-gruppe10/Backend)

### Evaluation/Benchmark setup
We have implemented a JUnit benchmark test: [Here](https://github.com/soft2018spring-gruppe10/Backend/blob/master/DBParadigmsGroup10/src/test/java/Interfaces/DatabaseBenchmarkTest.java)

This benchmark has static test data for queries in the database. It will do all 5 cases for each query. Using [vagrantfile](https://github.com/soft2018spring-gruppe10/Databases/blob/master/vagrantfile) to spin up a virtual machine, we can initialize a database with the init script and run the benchmark. We have chosen to measure from the DBMS to when the data is in the correct data model in the application (API). We do not measure the time it takes to jsoniny or send the json blob to the frontend. The connection to the virtual machine is a local connection, hence it should be unnoticeable.

```
$ ping 192.168.33.11

Pinging 192.168.33.11 with 32 bytes of data:
Reply from 192.168.33.11: bytes=32 time<1ms TTL=64
Reply from 192.168.33.11: bytes=32 time<1ms TTL=64
Reply from 192.168.33.11: bytes=32 time<1ms TTL=64
Reply from 192.168.33.11: bytes=32 time<1ms TTL=64

Ping statistics for 192.168.33.11:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 0ms, Maximum = 0ms, Average = 0ms
```
less than 1ms every time. Unable to accurately know how little. Most likely a lot less than 1ms. Hence we will not take this delay too seriously. However, it should be noted, that when developing application with databases, it shouldn't be neglected to consider where the database is and where the requester is. [Delay based on geography](https://github.com/DanielHauge/CPH-1st-Cemester/blob/master/Ressources/UFO/Prototype.md). If the database is located in a totally different far away location than the requester, then a constant delay might be added to the performance.

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

**Note:** MongoDB cannot query geospatial data without an index. [Proof / Picture error without index](https://i.gyazo.com/c7773dc00dcc617818e64a72d8959ebe.png)

### Optimized benchmark
See [neo4j.optimized](https://gist.github.com/Retroperspect/0f1a880ca44f932d21225dd9e5f379f4), [postgres.optimzed](https://gist.github.com/Retroperspect/a552b9b11e41e3cce8e3bc466cf3da51), [Mongo.optimized](https://gist.github.com/DanielHauge/2fb10e157b2616681d449923230e0949), [Mongo.GeoManualBenchmark](https://github.com/soft2018spring-gruppe10/Databases/blob/master/Documentation/MongoDBVicenetyBenchmark.txt)

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

**Important Note:** MongoDB doesn't have a compatible driver for java to do geospatial queries in aggregation. Hence results have been gained by running a manual benchmark in robo 3T. They still use same test queries. but are manually written. Test results [Here](https://github.com/soft2018spring-gruppe10/Databases/blob/master/Documentation/MongoDBVicenetyBenchmark.txt), also we havn't optimized Redis due to time constraints, and also it doesn't work with indexes.

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

We have 2 perspectives here. One with taking all the vicinity queries into consideration and one where we only take one of them(20km one) into consideration (unbiased one). However, we can form some idea of which database might be a preferred one if we consider speed. If we knew that we are going to make a lot of geospatial vicinity queries, we can definitely see from our results that MongoDB is a good choice for our setup. However, if we know that we are going to query "All books, cities, authors" Then MongoDB might not be a so good idea. In that case, Redis and Postgres is a better option. If we know that we are going to make a lot of queries based on relationships as "Mentions" then neo4j might be a better option, but maybe more if we wanted to do deeper relationship searches. If we knew that we were going to query different queries equally as much, and want the least amount of time overall, Postgres would be a good choice followed closely by MongoDB. All in all, the different databases all come with their strengths and weaknesses in different areas.

These results are gathered, but our own belief is that they do not prove anything totally. However, they do indicate an estimated reality. But the results are still influenced by a lot of factors, most noticeably the language used/Implementation (java), the data, end-user queries but also many other factors. eg. If we had parsed the data better to be able to handle multiple authors per book, an engine such as neo4j could have a node dedicated to authors and a relationship which could be "Contributed to". This way we could query based on label scan on the author instead of all the books. This goes for all databases except redis. But neo4j would be faster at getting a book by an author by doing a label scan on authors with a specific name and then find all books which it has a "Contributed to" relationship with. In addition, Postgres would also be faster at getting books by author, since there is no need for a wildcard search (regex), so that it can use an index and be super quick<sup>[2]</sup>. The language used is also of an influence of the results, these benchmarks are made mostly of an implementation written in Java. Java has been known for being slow, that is not 100% true any longer <sup>[3]</sup>. However as also stated, most libraries are often written for "correctness" and readability and not performance, this might definitely have had an influence on the results. These specific end-user queries also had a finger in the game when it comes to deciding the results. Most of the queries weren't really playing to neo4j's merits. The queries were also based on these well defined strict entities such as city and book and how a book mentions a city. 

These results are adequate estimates in our opinion, but to get better and accurate results. More prototype evaluation is needed, on a bigger sample size and with more end-user queries in more languages. What we could have done to make the results more precise is to have done more benchmark queries, ie. Make 100 benchmark cases and run the queries 5 times each, adding up to a total of 5000 queries.

The pro's and Con's we have experienced are similar to what other people have experienced/concluded: [KV-store](http://www.dotnetfunda.com/interviews/show/6385/what-are-the-pros-and-cons-of-using-key-value-store), as we've also experienced. Key-value stores don't feel as if meant to do these kinds of queries. [Document-oriented](https://halls-of-valhalla.org/beta/articles/the-pros-and-cons-of-mongodb,45/), since this is 4 years ago we haven't experienced the cons in such a heavy degree. But we did experience the spotty documentation, and missing driver aggregation implementation from it being a young DBMS, but also experienced its speed and flexibility, but also [MongoDB & Geospartial](https://scholarworks.umass.edu/cgi/viewcontent.cgi?article=1028&context=foss4g), We have definitely experienced that NoSQL(MongoDB) is performing quite better when it comes to handling geospatial queries. [SQL](http://www.cems.uwe.ac.uk/~pchatter/resources/html/rdb_strengths_weaknesses.html), poor representation of 'real world" entities and their relationships. Entities are fragmented into smaller relations through the process of normalization. This results in an inefficient design, as many joins may be required to recover data about that entity. This is a con but can also be seen as a pro. It is limiting redundancies and avoid update anomalies. We did not normalize authors which resulted in redundancies and potential update anomalies if we were to edit any of the authors(Which we didn't need for this). [Graph-based](https://www.quora.com/What-are-the-pros-and-cons-of-using-a-graph-database), we've also experienced that neo4j is a lot faster at searching based on relationships, but also that it requires to learn a new query language like cypher. Also other graph-based databases you'd need to learn a new language, and they might not be declarative or they might lack the capability to optimize queries properly.

### Recommendation
**IMPORTANT** - We would like to mention, that these recommendations would probably be different if for a different case. These recommendations are excluding "writes" as a feature. ie. It does not have any features that would require us to write to the databases. So these recommendations are mostly based on everything but "writes". 
#### In General
We would like to recommend in general:

- Neo4j for application features that requires searching for data based on relationships.

Neo4j is decent at most basic operations, but excel very much when it comes to searching for data based on relationships. It is using cypher as a query language but isn't too hard to learn. Also with docker, it is convenient to set up and make work. It also has an import tool which is decently fast at importing data. However, Neo4j comes at a cost which is, that it takes a lot of ram to run.

- Postgres for application features with a well-defined data model and low chance of changing.

Postgres is very good at almost every things but doesn't really excel heavily in one area. As can also be seen from the results, Postgres doesn't win in terms of speed in any of the queries but are the close follow up in almost all of them and win by an average of average. However, it also advised choosing this if data models are well defined and known with very little chance of changing in the future. Also, it is a relational DBMS where all that we know of is using SQL, which is very popular and have huge community and reception for support. Hence it is quite easy to migrate to another RDBMS because the queries and code can most likely be reused.

- MongoDB for application features that requires handling of geospatial data and queries.<sup>[4]</sup>

MongoDB is a very good all-around choice. It really excels as geospatial queries but is still fine as many other databases as other basic operations. However the DBMS is still a little young hence the compatibility with some languages might be lacking somewhat, also the documentation can be lacking too. It is a good choice for the future because it is very flexible. Data models can change without breaking the currently existing data. The data model doesn't have to be strictly defined which is very attractive to many developers.

- Redis for application features with very simple data, with known keys.

Redis is a powerful, efficient and fast when it comes to saving and getting values. However, there's a lack of a convenient way to search/scan. Most of its operations have a time complexity of O(1) which is very sought after because it means that no matter how much data grows, time to get data doesn't grow with it. However, it requires knowing the key to the value first. Hence it is challenged with searching for values if the key is unknown. The DBMS is easy to learn since most its operations are very simple, in addition to a very well written [documentation](https://redis.io/documentation)

#### For this Example
We will recommend MongoDB for this specific project, however with a different language than Java. One with better driver compatibility. It is clear to see that MongoDB is quite efficient with geospatial queries and data. In addition, it is flexible for change in the future. This is "Shelf" project, but if it weren't, you'd imagine implementing more features, which have a high chance of changing the data model.


[1]: https://github.com/DanielHauge/DBEX9
[2]: https://github.com/soft2018spring-gruppe10/Databases/blob/master/Documentation/Postgres%20Documentation.ipynb
[3]: https://stackoverflow.com/questions/2163411/is-java-really-slow
[4]: https://scholarworks.umass.edu/cgi/viewcontent.cgi?article=1028&context=foss4g
