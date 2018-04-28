wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/CitiesFinal.csv
docker run -p 5432:5432 --rm -d -v $(pwd)/:/root/ --name psql postgres:alpine
echo 'Docker running'
sleep 1s
docker exec psql sh -c "sed -i 1d /root/CitiesFinal.csv"
echo 'header lines removes'
docker exec psql sh -c "psql -U postgres -c 'CREATE TABLE cities(id INTEGER PRIMARY KEY, name VARCHAR, asciiname VARCHAR, latitude DOUBLE PRECISION, longitude DOUBLE PRECISION, cc VARCHAR, population INTEGER);'"
echo 'tables created. IMPORTING IS STARTING!'
docker exec psql sh -c "psql -U postgres -c '\copy cities FROM /root/CitiesFinal.csv CSV'"
docker exec psql sh -c "psql -U postgres -c 'CREATE INDEX cities_name_index ON cities USING btree("name");'"
docker exec psql sh -c "psql -U postgres -c 'CREATE INDEX cities_name_index ON cities USING btree("asciiname");'"
echo 'data imported'
