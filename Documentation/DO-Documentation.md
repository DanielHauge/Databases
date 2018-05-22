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
## To parse data to correct json format before importing:
