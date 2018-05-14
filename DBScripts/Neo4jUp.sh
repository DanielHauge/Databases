sudo mkdir import
sudo mkdir plugins

wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/Data/CitiesFinal.csv
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/Data/Books.csv
wget https://github.com/soft2018spring-gruppe10/Databases/raw/master/Data/BookMentions.csv
sudo mv $(pwd)/CitiesFinal.csv $(pwd)/import/CitiesFinal.csv
sudo mv $(pwd)/Books.csv $(pwd)/import/Books.csv
sudo mv $(pwd)/BookMentions.csv $(pwd)/import/BookMentions.csv
sudo sed -i -E '1s/.*/CityId:ID,name,latitude:FLOAT,longitude:FLOAT,cc,population:INT/' import/CitiesFinal.csv
sudo sed -i -E '1s/.*/BookId:ID,title,author/' import/Books.csv
sudo sed -i -E '1s/.*/:START_ID,:END_ID, amount:INT/' import/BookMentions.csv


sudo wget -P $(pwd)/plugins https://github.comgi/neo4j-contrib/neo4j-apoc-procedures/releases/download/3.3.0.1/apoc-3.3.0.1-all.jar
sudo wget -P $(pwd)/plugins https://github.com/neo4j-contrib/neo4j-graph-algorithms/releases/download/3.3.2.0/graph-algorithms-algo-3.3.2.0.jar

sudo docker run -d --name neo4j --publish=7474:7474 --publish=7687:7687 -v $(pwd)/import:/var/lib/neo4j/import -v $(pwd)/plugins:/var/lib/neo4j//plugins --env NEO4J_dbms_memory_pagecache_size=6G --env=NEO4J_dbms_memory_heap_max__size=10G --env NEO4J_AUTH=neo4j/class --env=NEO4J_dbms_security_auth__enabled=false --env=NEO4J_dbms_security_procedures_unrestricted=apoc.\\\*,algo.\\\* neo4j
sudo wget https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/DBScripts/Neo4jImport.sh
sudo chmod +x Neo4jImport.sh
echo "Now, please use this command: ./Neo4jImport.sh"
