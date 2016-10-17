#Build

docker build -t irenty/tinyproxy .

#Run detached
docker run --name="tinyproxy" -p6667:8888 -d irenty/tinyproxy

#Run in foreground
remove -d
