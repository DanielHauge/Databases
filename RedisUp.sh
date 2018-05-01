echo "Starting redis"
docker run -d --name redis -p 6379:6379 redis
echo "downloading .csv"
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/BookMentions.csv
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/Books.csv
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/CitiesFinal.csv
echo "Download done!."
awk -F, '{ print "SET", "book_title:"$1"", "\""$2"\"" }' Books.csv | unix2dos > titles
echo "Create titles"
awk -F, '{ print "SET", "book_author:"$1"", "\""$3"\"" }' Books.csv | unix2dos > authors
echo "Create authors"
awk -F, '{ print "SET", "city_name:"$1"", "\""$3"\"" }' CitiesFinal.csv | unix2dos > citynames
echo "Create citynames"
awk -F, '{ print "GEOADD", "geospartial", ""$4"", ""$5"", ""$1"" }' CitiesFinal.csv | unix2dos > places
echo "Create places"
awk -F, '{ print "SADD", "M_book-city:"$1"", ""$2"" }' BookMentions.csv | unix2dos > book-city
echo "Create book-city"
awk -F, '{ print "SADD", "M_city-book:"$2"", ""$1"" }' BookMentions.csv | unix2dos > city-book
echo "Create city-book"
docker cp titles redis:/root/titles
echo "Copy titles into container"
docker cp authors redis:/root/authors
echo "Copy authors into container"
docker cp citynames redis:/root/citynames
echo "Copy citynames into container"
docker cp places redis:/root/places
echo "Copy places into container"
docker cp book-city redis:/root/book-city
echo "Copy book-city into container"
docker cp city-book redis:/root/city-book
echo "Copy city-book into container"
docker exec -it redis sh -c 'cat /root/titles | redis-cli --pipe'
echo "Imported titles"
docker exec -it redis sh -c 'cat /root/authors | redis-cli --pipe'
echo "Imported authors"
docker exec -it redis sh -c 'cat /root/citynames | redis-cli --pipe'
echo "Imported citynames"
docker exec -it redis sh -c 'cat /root/places | redis-cli --pipe'
echo "Imported places"
docker exec -it redis sh -c 'cat /root/book-city | redis-cli --pipe'
echo "Imported book-city"
docker exec -it redis sh -c 'cat /root/city-book | redis-cli --pipe'
echo "Imported city-book"
echo "done"