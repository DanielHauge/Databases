# Neo4j Documentation
This is the Neo4j Documentation.

Neo4j was the least troublesome database together with postgres. It's compability with java was spotless and working with neo4j's browser is exellent, in addition to it's profile feature to tune queries during development of queries. There was some initial import problems, but was easily solved with a little bit of tinkering.

## Optimization:
We have optimized neo4j with indexes 
Cityid, Bookid, author. To make index work for geospartial queries. We had to refractor the type from latitude longitude to point. This can easily be achived by what we'd like to call "FindAndModify" query, but is basicly just a update all based on a query.

```cypher
MATCH(c:city)
SET c.location = point({longitude: c.longitude, latitude: c.latitude}), c.latitude= null, c.longitude= null;
```

It will find all cities and set a new attribute: location which is of type point, using it's own longitude and latitude, and afterwards setting the latitude and longitude to null, ie. Deleting them. As to not use up redundant space. We can afterwards index location.

To make the optimization, we've made a .cypher file with the steps to optimize the database. The file contains the following as plain text.
```
MATCH(c:city)
SET c.location = point({longitude: c.longitude, latitude: c.latitude}), c.latitude= null, c.longitude= null;

CREATE INDEX ON :city(location);
CREATE INDEX ON :city(Cityid);
CREATE INDEX ON :book(Bookid);
CREATE INDEX ON :book(author);
```
with this file we can cat it into the cypher shell from the operating system in the import script.

```
cat /path/to/Queries.cypher | bin/cypher-shell -u username -p password --format plain
```

With docker:

```
sudo docker exec -it neo4j sh -c 'cat /root/OptimNeo4j.cypher | bin/cypher-shell --format plain'
```

## Data structure.
As mentioned in the Data section in main database report. We do not support multiple authors that well. This means that neo4j needs to search all :books nodes and then do a unique check on them, to not send back redundand authors. For it to make alot more sense for neo4j, we would have wanted a seperate .csv file with authors and author id's and also a wrote.csv which represent the relationships between authors and books. We didn't do this because of time restraints. But this would have been a more elegant solution with better support for multiple authors. Furthermore reducing redundancy and avoiding update anomalies, luckily we do not have any features that would allow for updates nor writes.





