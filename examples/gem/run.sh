set -x
set -e

# Start artipie.
docker run --rm -d --name artipie -it -v $(pwd)/artipie.yaml:/etc/artipie/artipie.yml -v $(pwd):/var/artipie -p 8080:80 artipie/artipie:latest

# Wait for container to be ready for new connections.
sleep 5

gem --version
ruby --version
gem env --verbose
export GEM_HOST_API_KEY=$(echo -n "hello:world" | base64)

sudo apt install libssl1.0-dev

# sudo gem update --system
# sudo gem install rubygems-update --default
#sudo gem update --system '3.2.1' --debug --verbose --backtrace
#gem env --verbose
#gem list
#sudo gem uninstall rubygems -v '2.7.6'

#gem list
gem --version
# Push a gem into artipie.
cd sample-project
gem build sample-project.gemspec
#cd ../../src/test/resources/gem

#gem --version
ls
sleep 10
gem push sample-project-1.0.0.gem --host https://hello:world@localhost:8080/my-gem --debug --verbose --backtrace
#gem push rails-6.0.2.2.gem --host http://localhost:8080/my-gem

cd ..

# Fetch the uploaded earlier gem from artipie.
gem fetch sample-project --source http://localhost:8080/my-gem --debug --verbose --backtrace
#gem fetch rails --source http://localhost:8080/my-gem


# Remove container.
docker stop artipie
