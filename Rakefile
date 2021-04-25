require 'tempfile'

container_name = ENV['ISHIGAKI_CONTAINER_NAME'] || "ishigaki"
snapshot_name = "#{container_name}:snapshot"

full_version = File.read("VERSION").to_s.strip
major_version = full_version.split(".").slice(0..1).join(".")
minor_version = full_version.split(".").slice(0)

task :default => :refresh

task :refresh => [:build, :test]

desc "Build the Docker image"
task :build do

  tmp_file = Tempfile.new("docker")
  git_hash = `git rev-parse --short HEAD`

  rebuild_or_not = ENV["ISHIGAKI_FORCE_REBUILD"] ? "--pull --force-rm" : ""

  sh [
       "docker build --iidfile #{tmp_file.path}",
       "--label 'version=#{full_version}'",
       "--label 'org.opencontainers.image.revision=#{git_hash}'",
       rebuild_or_not,
       "./"
     ].join(" ")

  image_id = File.read(tmp_file.path).to_s.strip

  sh "docker tag #{image_id} ghcr.io/digital-identity-labs/#{container_name}:#{full_version}"
  sh "docker tag #{image_id} ghcr.io/digital-identity-labs/#{container_name}:#{major_version}"
  sh "docker tag #{image_id} ghcr.io/digital-identity-labs/#{container_name}:#{minor_version}"
  sh "docker tag #{image_id} ghcr.io/digital-identity-labs/#{container_name}:latest"
  sh "docker tag #{image_id} #{snapshot_name}"

end

desc "Rebuild the image"
task :rebuild => [:force_reset, :build]

desc "Build the image and test"
task :test => [:build] do
  begin
    sh "docker run -d -p 8080:8080 #{snapshot_name}"
    container_id = `docker ps -q -l`
    sleep ENV['CI'] ? 20 : 10
    colour = ENV['CI'] ? "--no-color" : "--color"
    sh "bundle exec inspec exec specs/ishigaki-internal/ #{colour} --chef-license accept -t docker://#{container_id} "
  ensure
    sh "docker stop #{container_id}" if container_id
  end
end

task :shell => [:build] do
  sh "docker run -d -p 8080:8080 #{snapshot_name}"
  container_id = `docker ps -q -l`.chomp
  sh "docker exec -it #{container_id} /bin/bash"
end

task :export => [:build] do
  sh "docker run -d -p 8080:8080 #{snapshot_name}"
  container_id = `docker ps -q -l`.chomp
  sh "mkdir -p exported_optfs/"
  sh "docker cp #{container_id}:/opt/shibboleth-idp/ exported_optfs/shibboleth-idp"
  sh "docker cp #{container_id}:/opt/jetty-shib/ exported_optfs/jetty-shib"
  sh "docker stop #{container_id}"
end

desc "Build and publish a Docker image to Github (it's usually better to use github:release)"
task publish: [:build] do

  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:#{full_version}"
  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:#{major_version}"
  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:#{minor_version}"
  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:latest"

end

task :force_reset do
  ENV["ISHIGAKI_FORCE_REBUILD"] = "yes"
end

# task :push do
#
#   branch = (ENV['TRAVIS_BRANCH'] || `git symbolic-ref --short HEAD`).to_s.downcase.chomp
#   repo = "digitalidentity/ishigaki"
#   tag  = (branch == "master" ? "latest" : (branch || "snapshot")).to_s.downcase.chomp
#   image_name = "#{repo}:#{tag}"
#
#   if ["develop", "snapshot"].include?(branch)
#     puts "Not pushing: Can push to Docker Hub only from master or stable release tags"
#     exit 1
#   end
#
#   puts "Building, testing and pushing #{image_name} to Docker Hub from #{branch} branch"
#   sh "docker build -t #{image_name} ."
#   image_version = `docker image inspect -f '{{.Config.Labels.version}}' #{image_name}`
#   puts "  version: #{image_version}"
#   sh "docker push #{repo}"
#
# end
