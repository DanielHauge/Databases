echo "Starting redis"
docker run -d --name redis -p 6379:6379 redis
echo "downloading .csv"
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/BookMentions.csv
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/Books.csv
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/CitiesFinal.csv
echo "Download done!."
awk -F, '{ print "SET", "book_title:"$1"", "\""$2"\"" }' Books.csv | unix2dos >> commands
echo "Create titles"
awk -F, '{ print "SET", "book_author:"$1"", "\""$3"\"" }' Books.csv | unix2dos >> commands
echo "Create authors"
awk -F, '{ print "SET", "city_name:"$1"", "\""$3"\"" }' CitiesFinal.csv | unix2dos >> commands
echo "Create citynames"
awk -F, '{ print "GEOADD", "geospartial", ""$4"", ""$5"", ""$1"" }' CitiesFinal.csv | unix2dos >> commands
echo "Create places"
awk -F, '{ print "SADD", "M_book-city:"$1"", ""$2"" }' BookMentions.csv | unix2dos >> commands
echo "Create book-city"
awk -F, '{ print "SADD", "M_city-book:"$2"", ""$1"" }' BookMentions.csv | unix2dos >> commands
echo "Create city-book"
docker cp commands redis:/root/commands
echo "Copy commands into container"
docker exec -it redis sh -c 'cat /root/commands | redis-cli --pipe'
echo "Imported commands"

echo "done"