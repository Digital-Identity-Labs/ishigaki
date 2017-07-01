
task :default => :refresh

task :refresh => [:build, :test]

desc "Build the image"
task :build do
  sh "docker build --pull -t digitalidentitylabs/ishigaku:snapshot ."
end

desc "Rebuild the image"
task :rebuild do
  sh "docker build --pull --force-rm -t digitalidentitylabs/ishigaku:snapshot ."
end

desc "Build the image and test"
task :test => [:build] do
  begin
    sh "docker run -d -p 8080:8080 digitalidentitylabs/ishigaku:snapshot"
    container_id = `docker ps -q -l`
    sleep ENV['CI'] ? 20 : 10
    colour = ENV['CI'] ? "--no-color" : "--color"
    sh "bundle exec inspec exec specs/ishigaki-internal/ #{colour} -t docker://#{container_id} "
  ensure
    sh "docker stop #{container_id}" if container_id
  end
end

task :shell => [:build] do
  sh "docker run -d -p 8080:8080 digitalidentitylabs/ishigaku:snapshot"
  container_id = `docker ps -q -l`.chomp
  sh "docker exec -it #{container_id} /bin/bash"
end

task :push do

  branch = (ENV['TRAVIS_BRANCH'] || `git symbolic-ref --short HEAD`).to_s.downcase.chomp
  repo = "digitalidentity/ishigaki"
  tag  = (branch == "master" ? "latest" : (branch || "snapshot")).to_s.downcase.chomp
  image_name = "#{repo}:#{tag}"

  if ["develop", "snapshot"].include?(branch)
    puts "Not pushing: Can push to Docker Hub only from master or stable release tags"
    exit 1
  end

  puts "Building, testing and pushing #{image_name} to Docker Hub from #{branch} branch"
  sh "docker build -t #{image_name} ."
  image_version = `docker image inspect -f '{{.Config.Labels.version}}' #{image_name}`
  puts "  version: #{image_version}"
  sh "docker push #{repo}"

end

