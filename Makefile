clean-cache:
	ssh user101@101companies.org -t "redis-cli FLUSHDB"

reset-tours-demo-data:
	exec mongoimport --drop -d wiki_development -c tours db/tours_demo.json
