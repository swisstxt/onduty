IMAGE=onduty
VERSION=`cat VERSION`

docker build -t $IMAGE:v$VERSION .
docker tag $IMAGE:v$VERSION $IMAGE:latest
docker push repo.swisstxt.ch:5000/$IMAGE
