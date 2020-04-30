
REGISTRY=docker.swisstxt.ch
IMAGE=onduty
VERSION=`awk -F'"' '$0=$2' lib/onduty/version.rb`

#
# Ensure that the working copy is clean
#
if [ "$(git status --porcelain | wc -l)" -ne 0 ];
then
    echo "Please commit or stash your pending changes first! See below:"
    git status --porcelain
    exit 1
fi

#
# Ensure that the code has been tagged and published
#
git ls-remote --tags origin | grep v${VERSION} > /dev/null
if [ $? != 0 ];
then
    echo "First, please create and push git tag 'v${VERSION}' ;-)"
    exit 2
fi

#
# Synchronize git tags
#
echo "Checkout v${VERSION} from git"
git pull --tags && git checkout v${VERSION}

if [ $? != 0 ];
then
    echo "Aborting since something bad happened, see messages above for details."
    exit 3
fi

# intentionally not using the '--pull' flag here
docker build --force-rm --no-cache --compress -t $IMAGE:v$VERSION .

docker tag $IMAGE:v$VERSION $IMAGE:latest
docker tag $IMAGE:v$VERSION $REGISTRY/$IMAGE:v$VERSION
docker tag $IMAGE:v$VERSION $REGISTRY/$IMAGE:latest
docker push $REGISTRY/$IMAGE

echo -e "\n...Finished! Let's go back to master branch..."
git checkout master
