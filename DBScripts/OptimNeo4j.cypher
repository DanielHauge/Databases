MATCH(c:city)
SET c.location = point({longitude: c.longitude, latitude: c.latitude}), c.latitude= null, c.longitude= null;

CREATE INDEX ON :city(location);
CREATE INDEX ON :city(Cityid);
CREATE INDEX ON :book(Bookid);
CREATE INDEX ON :book(author);