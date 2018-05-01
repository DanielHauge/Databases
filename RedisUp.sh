echo "Starting redis"
docker run -d --name redis -p 6379:6379 redis
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/BookMentions.csv
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/Books.csv
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/CitiesFinal.csv
awk -F, '{ print "SET", "\"book_title:"$1"\"", "\""$2"\"" }' Books.csv | unix2dos > titles
awk -F, '{ print "SET", "\"book_author:"$1"\"", "\""$3"\"" }' Books.csv | unix2dos > authors
awk -F, '{ print "SET", "\"city_name:"$1"\"", "\""$3"\"" }' CitiesFinal.csv | unix2dos > citynames
awk -F, '{ print "GEOADD", "\"geospartial\"", "\""$4"\"", "\""$5"\"", "\""$1"\"" }' CitiesFinal.csv | unix2dos > places
awk -F, '{ print "SADD", "\"M_book-city:"$1"\"", "\""$2"\"" }' BookMentions.csv | unix2dos > book-city
awk -F, '{ print "SADD", "\"M_city-book:"$2"\"", "\""$1"\"" }' BookMentions.csv | unix2dos > city-book
docker cp titles redis:/root/titles
docker cp authors redis:/root/authors
docker cp citynames redis:/root/citynames
docker cp places redis:/root/places
docker cp book-city redis:/root/book-city
docker cp city-book redis:/root/city-book
docker exec redis bash -sh 'cat /root/titles | redis-cli --pipe'
docker exec redis bash -sh 'cat /root/authors | redis-cli --pipe'
docker exec redis bash -sh 'cat /root/citynames | redis-cli --pipe'
docker exec redis bash -sh 'cat /root/places | redis-cli --pipe'
docker exec redis bash -sh 'cat /root/book-city | redis-cli --pipe'
docker exec redis bash -sh 'cat /root/city-book | redis-cli --pipe'
echo "done"
