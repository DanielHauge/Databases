# MongoDB

## Queries to lookup on another collection

```
db.mentions.aggregate([
    {
            $match : { "Bookid": 1 }
    },
    {
        $lookup : {
            from: "cities",
            localField: "Cityid",
            foreignField: "Cityid",
            as: "city"
        }
    }
])
```
## Handling geospartial tasks.
The data structure most uphold the geoJson format found in this [link](https://docs.mongodb.com/manual/reference/geojson/).
Therefor we have been forced to refractor the data which contained the geospartial data. we have done this with a sed command:
```
sudo sed 's/\([^,]*\),\([^,]*\),\([0-9.-]*\),\([0-9.-]*\),\([^,]*\),\([^,]*\)/{ "Cityid" : \1, "Name" : \"\2\", "CC" : \"\5\", "pop" : \6, "location" : { "type" : "Point", "coordinates" : [ \4, \3 ] } }/' < CitiesFinal.csv > cities.json
```
#### Command
- ```sed``` = Stream editor
- ```s/``` = substitution mode
- ```\([^,]*\),``` = find any string before , and use it as [1]
- ```\([^,]*\),``` = Find next stringt before , and use it as [2]
- ```\([0-9.-]*\),``` = find the next sequence of numbers before , and use it as [3]
- ```\([0-9.-]*\),``` = find the next sequence of numbers before , and use it as [4]
- ```\([^,]*\),``` = find the next string before , and use it as [5]
- ```\([^,]*\)``` = find the next string and use it as [6]
- ```/{ "Cityid" : \1, "Name" : \"\2\", "CC" : \"\5\", "pop" : \6, "location" : { "type" : "Point", "coordinates" : [ \4, \3 ] } }/``` = Now format to json, and using according valid geoJson structure with location -> type:point, coords:[x,y].
- ```< CitiesFinal.csv``` = use CitiesFinal.csv as source for the operation
- ```> cities.json``` = write it to file cities.json

#### Index
Now with the data correctly in database with the valid Geojson format.
[![https://gyazo.com/a745489f7360de58219f79cf36124694](https://i.gyazo.com/a745489f7360de58219f79cf36124694.png)](https://gyazo.com/a745489f7360de58219f79cf36124694)

We have to geoindex it. We can do this by the following command:
```
db.cities.createIndex({ location: "2dsphere" })
```

Why do we want to index it?. The answer can be found here [Lecture notes](https://github.com/datsoftlyngby/soft2018spring-databases-teaching-material/blob/master/lecture_notes/03-MongoDB_Modelling.ipynb). But simply because it makes the lives of programmers easier, also we don't have to calculate the correctly spherical distance from point to point on every query.

#### Query
Now we can query geoWithin a specific location. as follows:
```
db.cities.find({
    location: { $geoWithin: { $centerSphere: [
        [ 11.47, 52.38 ] , 20000 / 6378100.0 ] }
    }
})
```

Vicenety aggregation example:
```
db.cities.aggregate([
    {
        $geoNear: {
            near: { type: "Point", coordinates: [11.47, 52.38] },
            distanceField: "dist.calculated",
            maxDistance: 20000,
            includeLocs: "location",
            spherical: true
        }
    },
    {
        $lookup: 
        {
            from: "mentions",
            localField: "Cityid",
            foreignField: "Cityid",
            as: "Ments"
            
        }
    },
    {
        $lookup:
        {
            from: "books",
            localField: "Ments.Bookid",
            foreignField: "Bookid",
            as: "Books"
        }
    }
])
```

#### Performance
We have index the following:

```
db.books.createIndex({"Bookid": 1})
db.books.createIndex({"Author": 1})
db.mentions.createIndex({"Bookid": 1})
db.mentions.createIndex({"Cityid": 1})
db.cities.createIndex({"Cityid": 1})
```

#### Reflection
Initialy we didn't get a very good impression of mongodb. It felt clunky, sluggish and following weird customs. But this was a byproduct of being too used to the relational database world. After some time and getting used to think differently, we got more fond of the NoSQL way of thinking. The documentataion of MongoDB is a little spotty, but somehow manage to do most things pretty well.

However, in hindsight we believe it realy matters what programming language is used when choosing database. Java drivers for mongodb does not have $geoNear aggregation step. Therefor we are unable to do vicenety lookups based on a aggregation in the java API, and are either forced to not do it because of time restraint or do a ugly quadratic solution with tons of queries to the database, which we are not to stoked to do.
