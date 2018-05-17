wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/Data/CitiesFinal.csv
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/Data/Books.csv
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/Data/BookMentions.csv
docker run --rm -d -v $(pwd)/:/root/ --name psql postgres:alpine
echo 'Docker running'
sleep 2s
docker exec psql sh -c "sed -i 1d /root/CitiesFinal.csv"
docker exec psql sh -c "sed -i 1d /root/Books.csv"
docker exec psql sh -c "sed -i 1d /root/BookMentions.csv"
echo 'header lines removes'
sleep 2s
docker exec psql sh -c "psql -U postgres -c 'CREATE TABLE cities(id INTEGER PRIMARY KEY, name VARCHAR, latitude DOUBLE PRECISION, longitude DOUBLE PRECISION, cc VARCHAR, population INTEGER);'"
docker exec psql sh -c "psql -U postgres -c 'CREATE TABLE books(id INTEGER PRIMARY KEY, title VARCHAR, author VARCHAR);'"
echo 'tables created. IMPORTING IS STARTING!'
sleep 1s
docker exec psql sh -c "psql -U postgres -c '\copy cities FROM /root/CitiesFinal.csv CSV'"
docker exec psql sh -c "psql -U postgres -c '\copy books FROM /root/Books.csv CSV'"
docker exec psql sh -c "psql -U postgres -c 'CREATE TABLE mentions(bookid INTEGER references books(id), cityid INTEGER references cities(id), amount INTEGER);'"
sleep 1s
docker exec psql sh -c "psql -U postgres -c '\copy mentions FROM /root/BookMentions.csv CSV'"
docker exec psql sh -c "psql -U postgres -c 'CREATE INDEX cities_name_index ON cities USING btree("name");'"
wget https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/DBScripts/Geofunction.sql
docker cp Geofunction.sql psql:/root/Geofunction.sql
docker exec psql sh -c "psql -U postgres < /root/Geofunction.sql"
echo 'data imported'
