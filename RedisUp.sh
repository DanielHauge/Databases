echo "Starting redis"
docker run -d --name redis -p 6379:6379 redis
echo "downloading .csv"
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/BookMentions.csv
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/Books.csv
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/CitiesFinal.csv
echo "Download done!."
awk -F, 'NR > 1{ print "SET", "book_title:"$1"", "\""$2"\"" "\n" "SET", "book_author:"$1"", "\""$3"\"" "\n" "SADD", "Athor-book:""\""$3"\"", ""$1"" "\n" "SADD", "AllAuthors", "\""$2"\""}' Books.csv | unix2dos > book
echo "Create title, authors and author->book"
awk -F, 'NR > 1{ print "SET", "city_name:"$1"", "\""$2"\"", "\n" "HSET", "AllCities", "id", $1, "name","\""$2"\""}' CitiesFinal.csv | unix2dos > city
echo "Create citynames and all cities"
awk -F, 'NR > 1{ print "GEOADD", "geospartial", ""$4"", ""$3"", ""$1"" }' CitiesFinal.csv | unix2dos > places
echo "Create places"
awk -F, 'NR > 1{ print "SADD", "M_book-city:"$1"", ""$2"", "\n" "SADD", "M_city-book:"$2"", ""$1"" }' BookMentions.csv | unix2dos > mentions
echo "Create mentions"

docker cp book redis:/root/book
echo "Copy book into container"
docker cp city redis:/root/city
echo "Copy city into container"
docker cp places redis:/root/places
echo "Copy places into container"
docker cp mentions redis:/root/mentions
echo "Copy mentions into container"

docker exec -it redis sh -c 'cat /root/book | redis-cli --pipe'
echo "Imported book"
docker exec -it redis sh -c 'cat /root/city | redis-cli --pipe'
echo "Imported city"
docker exec -it redis sh -c 'cat /root/places | redis-cli --pipe'
echo "Imported places"
docker exec -it redis sh -c 'cat /root/mentions | redis-cli --pipe'
echo "Imported mentions"

echo "done"