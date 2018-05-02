# Redis

## Running cli
```
docker run -it --rm --link redis:redis redis bash -c 'redis-cli -h redis'
```

### Books and authors

add book titles
```
awk -F, '{ print "SET", "\"book_title:"$1"\"", "\""$2"\"" }' TestBooks.csv
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
