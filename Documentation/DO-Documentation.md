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
sed 's/\([^,]*\),\([^,]*\),\([0-9.-]*\),\([0-9.-]*\),\([^,]*\),\([^,]*\)/{ Cityid: \1, Name: \2, cc: \5, pop: \6 location:{ type: "Point", coordinates: [ \4, \3 ] } }/' <CitiesFinal.csv >cities.json
```
#### Command
- sed = Stream editor
- s/ = substitution mode
- \([^,]*\), = find any string before , and use it as [1]
- \([^,]*\), = Find next stringt before , and use it as [2]
- \([0-9.-]*\), = find the next sequence of numbers before , and use it as [3]
- \([0-9.-]*\), = find the next sequence of numbers before , and use it as [4]
- \([^,]*\), = find the next string before , and use it as [5]
- \([^,]*\) = find the next string and use it as [6]
- /{ Cityid: \1, Name: \2, cc: \5, pop: \6 location:{ type: "Point", coordinates: [ \4, \3 ] } }/' = Now format to json, and using according valid geoJson structure with location -> type:point, coords:[x,y].
- < CitiesFinal.csv = use CitiesFinal.csv as source for the operation
- \>cities.json = write it to file cities.json


