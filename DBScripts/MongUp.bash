wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/Data/CitiesFinal.csv
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/Data/Books.csv
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/Data/BookMentions.csv
sed -i 1d /root/CitiesFinal.csv
sed 's/\([^,]*\),\([^,]*\),\([0-9.-]*\),\([0-9.-]*\),\([^,]*\),\([^,]*\)/{ Cityid: \1, Name: \2, cc: \5, pop: \6 location:{ type: "Point", coordinates: [ \4, \3 ] } }/' <CitiesFinal.csv >cities.json


sudo docker run --name mongo -p 27017:27017 -d mongo

sudo docker cp cities.json mongo:/root/cities.json
sudo docker cp Books.csv mongo:/root/Books.csv
sudo docker cp BookMentions.csv mongo:/root/BookMentions.csv


sudo docker exec mongo sh -c "mongoimport -d mydb -c cities --type json --file /root/cities.json"
sudo docker exec mongo sh -c "mongoimport -d mydb -c books --type csv --file /root/Books.csv --headerline"
sudo docker exec mongo sh -c "mongoimport -d mydb -c mentions --type csv --file /root/BookMentions.csv --headerline"

sudo rm CitiesFinal.csv
sudo rm Books.csv
sudo rm BookMentions.csv
