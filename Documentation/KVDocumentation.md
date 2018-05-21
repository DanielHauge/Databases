# Redis

## Running a test cli
```
docker run -it --rm --link redis:redis redis bash -c 'redis-cli -h redis'
```

### Books and authors
We have used awk to construct and append import commands for redis into a flat file. Like below: This is just some tests to get a feel for how we import. This decision to do it like this, was what we could find was the fastest way to import data. Compared to other solutions as: Making a program to insert values from reading a CSV file. This way we can also stick to linux operating systems tools instead of having to write programs to do tasks like these.

add book titles
```
awk -F, '{ print "SET", "\"book_title:"$1"\"", "\""$2"\"" }' TestBooks.csv
```
example:
```
SET book_title:15 "Moby dick"
```

add book authos
```
awk -F, '{ print "SET", "\"book_author:"$1"\"", "\""$3"\"" }' TestBooks.csv
```

### City & geospartial stuff

add cities names.
```
awk -F, '{ print "SET", "\"city_name:"$1"\"", "\""$3"\"" }' TestCities.csv
```

add city locations
```
awk -F, '{ print "GEOADD", "\"geospartial\"", "\""$4"\"", "\""$5"\"", "\""$1"\"" }' TestCities.csv
```

To get city names
```
GET city_name:<id of city>
```

To query for vicenery things.
```
GEOADD geospartial <longitude> <latitude> tempplace
GEORADIUSBYMEMBER geospartial tempplace 100 km
ZREM geospartial tempplace
```


### Mentions

add mentions to book -> city
```
awk -F, '{ print "SADD", "\"M_book-city:"$1"\"", "\""$2"\"" }' TestMentions.csv
```

add mentions to city <- book
```
awk -F, '{ print "SADD", "\"M_city-book:"$2"\"", "\""$1"\"" }' TestMentions.csv
```

To get all mentions from either:
```
SMEMBERS key (M_book-city:<id of book>)
or...
SMEMBERS key (M_city-book:<id of city>)
```

### Structure
Redis are able to have complex types with different fields and more. usualy a key-value store can handle this by having keys and values. But we have chossen er more straightforward solution, mostly because our experimentation showed a huge performance increase, downside is that there will occur some redundancy. But a cost we are willing to pay. This way, (In our opinion) it can also highlight some of the advantages and disadvantages of redis.

A very good advantage we've encountered by working with redis is most it's operations take O(1) in time complexity. Which is very good when handling very huge data sets. Getting a title from bookid 52525 takes no time for redis, where'as other DBMS might need to search alot of data before finding the title, allthough indexes can help alot in finding the title, redis doesn't need it. In the other hand redis has all it's data in memory, so its also costly to be able to get the title at O(1) every time.

### Known issues
We have encountered 12 issues with commands generated from the books.csv file. This results in a few missing authors or booktitles. We do currently not know exactly what is causing these errors. But it is highly theorized that the commands constructed by awk, makes invalid commands in a few instances. Similar to SQL injection, some titles or authors might contain special signs that might corrupt the SET commands consturcted. But considering time constraints, we have chosen to leave it as is. Idealy we would want to fix this, by making a custom configuration that whould be able to save the error log when using the redis pipe cli.

### Analysing.
When running the commandstats command in redis. This is what it shows. It shows that many of the commands are very fast. except for smsmebers. The reasoning is that there is alot of members in these typically. So it has to chow them all each time which takes some time. Geo calls are also taking a little bit more time than the other commands, such as get.
```
cmdstat_ping:calls=75,usec=105,usec_per_call=1.40
cmdstat_georadiusbymember:calls=96,usec=7363,usec_per_call=76.70
cmdstat_command:calls=1,usec=444,usec_per_call=444.00
cmdstat_zrem:calls=59,usec=556,usec_per_call=9.42
cmdstat_sadd:calls=3089090,usec=5369028,usec_per_call=1.74
cmdstat_set:calls=122813,usec=187456,usec_per_call=1.53
cmdstat_geopos:calls=769,usec=12964,usec_per_call=16.86
cmdstat_geoadd:calls=48533,usec=209251,usec_per_call=4.31
cmdstat_echo:calls=4,usec=5,usec_per_call=1.25
cmdstat_smembers:calls=1552,usec=16784780,usec_per_call=10814.94
cmdstat_get:calls=41820,usec=142379,usec_per_call=3.40
```
