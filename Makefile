clean-cache:
	ssh user101@101companies.org -t "redis-cli FLUSHDB"
