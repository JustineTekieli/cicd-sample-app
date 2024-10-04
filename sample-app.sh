#!/bin/bash
set -euo pipefail

# Check if tempdir exists and remove it if it does
if [ -d "tempdir" ]; then
    echo "Removing existing tempdir..."
    rm -rf tempdir
fi

# Create a new tempdir
echo "Creating tempdir..."
mkdir tempdir

# Create subdirectories
mkdir -p tempdir/templates
mkdir -p tempdir/static

echo "Copying files..."
cp sample_app.py tempdir/.
cp -r templates/* tempdir/templates/.
cp -r static/* tempdir/static/.

echo "Creating Dockerfile..."
cat > tempdir/Dockerfile << _EOF_
FROM python
RUN pip install flask
COPY  ./static /home/myapp/static/
COPY  ./templates /home/myapp/templates/
COPY  sample_app.py /home/myapp/
EXPOSE 5050
CMD python /home/myapp/sample_app.py
_EOF_

cd tempdir || exit

# Stop and remove existing container if it exists
if [ "$(docker ps -q -f name=samplerunning)" ]; then
    docker stop samplerunning
    docker rm samplerunning
fi

echo "Building Docker image..."
docker build -t sampleapp .

echo "Running Docker container..."
docker run -t -d -p 5050:5050 --name samplerunning sampleapp

echo "Listing Docker containers..."
docker ps -a
