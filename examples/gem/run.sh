set -x
set -e

# Start artipie.
docker run --rm -d --name artipie -it -v $(pwd)/artipie.yaml:/etc/artipie/artipie.yml -v $(pwd):/var/artipie -p 8080:80 artipie/artipie:latest

# Wait for container to be ready for new connections.
sleep 5

gem --version
ruby --version
#sudo gem update --system
gem --version
# Push a gem into artipie.
export GEM_HOST_API_KEY=$(echo -n "hello:world" | base64)
#cd sample-project
#gem build sample-project.gemspec
cd ../../src/test/resources/gem/rails-6.0.2.2.gem
gem --version
#gem push sample-project-1.0.0.gem --host http://localhost:8080/my-gem
gem push rails-6.0.2.2.gem --host http://localhost:8080/my-gem

cd ..

gem --version
# Fetch the uploaded earlier gem from artipie.
#gem fetch sample-project --source http://localhost:8080/my-gem
gem fetch rails --source http://localhost:8080/my-gem


# Remove container.
docker stop artipie
