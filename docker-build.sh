IMAGE=onduty
VERSION=`awk -F'"' '$0=$2' lib/onduty/version.rb`

docker build -t $IMAGE:v$VERSION .
docker tag $IMAGE:v$VERSION $IMAGE:latest
docker tag $IMAGE:v$VERSION docker.swisstxt.ch/$IMAGE:v$VERSION
docker tag $IMAGE:v$VERSION docker.swisstxt.ch/$IMAGE:latest
docker push docker.swisstxt.ch/$IMAGE
