sudo docker exec neo4j sh -c 'neo4j stop'
sudo docker exec neo4j sh -c 'rm -rf /var/lib/neo4j/data/databases/graph.db'
sudo docker exec neo4j sh -c 'rm -rf data/databases/graph.db'
sudo docker exec -it neo4j sh -c 'neo4j-admin import --nodes:city import/CitiesFinal.csv --nodes:book import/Books.csv --relationships:MENTIONS import/BookMentions.csv --ignore-missing-nodes=true --ignore-duplicate-nodes=true --id-type=INTEGER'
sudo docker restart neo4j