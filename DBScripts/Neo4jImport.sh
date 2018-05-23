sudo docker exec neo4j sh -c 'neo4j stop'
sudo docker exec neo4j sh -c 'rm -rf /var/lib/neo4j/data/databases/graph.db'
sudo docker exec neo4j sh -c 'rm -rf data/databases/graph.db'
sudo docker exec -it neo4j sh -c 'neo4j-admin import --nodes:city import/CitiesFinal.csv --nodes:book import/Books.csv --relationships:MENTIONS import/BookMentions.csv --ignore-missing-nodes=true --ignore-duplicate-nodes=true --id-type=INTEGER'
sudo docker restart neo4j
sudo sleep 1s
sudo wget https://raw.githubusercontent.com/soft2018spring-gruppe10/Databases/master/DBScripts/OptimNeo4j.cypher
sudo docker cp OptimNeo4j.cypher neo4j:/root/OptimNeo4j.cypher
echo "sudo docker exec -it neo4j sh -c 'cat /root/OptimNeo4j.cypher | bin/cypher-shell --format plain'"
