wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/Data/CitiesFinal.csv
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/Data/Books.csv
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/Data/BookMentions.csv

sudo docker run --name mongo -d mongo

sudo docker cp CitiesFinal.csv mongo:/root/CitiesFinal.csv
sudo docker cp Books.csv mongo:/root/Books.csv
sudo docker cp BookMentions.csv mongo:/root/BookMentions.csv

sudo docker exec mongo sh -c "mongoimport -d mydb -c cities --type csv --file /root/CitiesFinal.csv --headerline"
sudo docker exec mongo sh -c "mongoimport -d mydb -c books --type csv --file /root/Books.csv --headerline"
sudo docker exec mongo sh -c "mongoimport -d mydb -c mentions --type csv --file /root/BookMentions.csv --headerline"

sudo rm CitiesFinal.csv
sudo rm Books.csv
sudo rm BookMentions.csv