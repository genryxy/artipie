set -x
set -e

# Start artipie.
docker run --rm -d --name artipie -it -v $(pwd)/artipie.yaml:/etc/artipie/artipie.yml -v $(pwd):/var/artipie -p 8080:80 artipie/artipie:latest

# Wait for container to be ready for new connections.
sleep 5

# Push a gem into artipie.
export GEM_HOST_API_KEY=$(echo -n "hello:world" | base64)
cd sample-project
gem build sample-project.gemspec

gem sources -r https://rubygems.org/ --debug --verbose --backtrace
gem sources -a http://localhost:8080/my-gem --debug --verbose --backtrace

#/bin/bash -c "GEM_HOST_API_KEY=$(echo -n "hello:world" | base64) gem push sample-project-1.0.0.gem --host http://localhost:8080/my-gem --debug --verbose --backtrace"
gem push sample-project-1.0.0.gem --debug --verbose --backtrace

cd ..

# Fetch the uploaded earlier gem from artipie.
#/bin/bash -c "GEM_HOST_API_KEY=$(echo -n "hello:world" | base64) gem fetch sample-project --source http://localhost:8080/my-gem --debug --verbose --backtrace"
gem fetch sample-project --debug --verbose --backtrace

#/bin/bash -c "GEM_HOST_API_KEY=$(echo -n "hello:world" | base64) gem fetch sample-project --source http://localhost:8080/my-gemempty --debug --verbose --backtrace"

# Remove container.
docker stop artipie
