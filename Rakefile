require 'tempfile'

container_name = ENV['ISHIGAKI_CONTAINER_NAME'] || "ishigaki"
snapshot_name = "#{container_name}:snapshot"

full_version = File.read("VERSION").to_s.strip
major_version = full_version.split(".").slice(0..1).join(".")
minor_version = full_version.split(".").slice(0)

task :default => :refresh

task :refresh => [:build, :test]

desc "Build the default Docker image"
task :build => ["build:generic"]

namespace :build do

  desc "Build all versions"
  task :all => ["build:generic", "build:base", "build:plus"]

  desc "Build the Docker image (generic)"
  task :generic do

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
    sh "docker tag #{image_id} digitalidentity/#{container_name}:#{full_version}"
    sh "docker tag #{image_id} digitalidentity/#{container_name}:latest"
    sh "docker tag #{image_id} #{snapshot_name}"

  end

  desc "Build the Docker image for use a base image"
  task :base do

    tmp_file = Tempfile.new("docker")
    git_hash = `git rev-parse --short HEAD`

    rebuild_or_not = ENV["ISHIGAKI_FORCE_REBUILD"] ? "--pull --force-rm" : ""

    sh [
         "docker build --iidfile #{tmp_file.path}",
         "--build-arg WRITE_MD=0",
         "--build-arg EDWIN_STARR=1",
         "--build-arg DELAY_WAR=1",
         "--build-arg MODULES=''",
         "--build-arg PLUGINS=''",
         "--label 'version=#{full_version}'",
         "--label 'org.opencontainers.image.revision=#{git_hash}'",
         rebuild_or_not,
         "./"
       ].join(" ")

    image_id = File.read(tmp_file.path).to_s.strip

    sh "docker tag #{image_id} ghcr.io/digital-identity-labs/#{container_name}:#{full_version}-base"
    sh "docker tag #{image_id} ghcr.io/digital-identity-labs/#{container_name}:#{major_version}-base"
    sh "docker tag #{image_id} ghcr.io/digital-identity-labs/#{container_name}:#{minor_version}-base"
    sh "docker tag #{image_id} ghcr.io/digital-identity-labs/#{container_name}:latest-base"
    sh "docker tag #{image_id} #{snapshot_name}-base"

  end

  desc "Build the Docker image (including extra plugins)"
  task :plus do

    tmp_file = Tempfile.new("docker")
    git_hash = `git rev-parse --short HEAD`

    rebuild_or_not = ENV["ISHIGAKI_FORCE_REBUILD"] ? "--pull --force-rm" : ""

    plugin_urls = [
      "https://shibboleth.net/downloads/identity-provider/plugins/oidc-common/1.1.0/oidc-common-dist-1.1.0.tar.gz",
      "https://shibboleth.net/downloads/identity-provider/plugins/totp/1.0.0/idp-plugin-totp-dist-1.0.0.tar.gz",
      "https://shibboleth.net/downloads/identity-provider/plugins/scripting/1.0.0/idp-plugin-nashorn-dist-1.0.0.tar.gz",
      "https://shibboleth.net/downloads/identity-provider/plugins/oidc-op/3.0.1/idp-plugin-oidc-op-distribution-3.0.1.tar.gz"
    ].join(" ")

    sh [
         "docker build --iidfile #{tmp_file.path}",
         "--build-arg WRITE_MD=0",
         "--build-arg DELAY_WAR=1",
         "--build-arg MODULES=''",
         "--build-arg PLUGINS='#{plugin_urls}'",
         "--build-arg PLUGIN_MODULES='idp.oidc.OP, idp.authn.TOTP'",
         "--label 'version=#{full_version}'",
         "--label 'org.opencontainers.image.revision=#{git_hash}'",
         rebuild_or_not,
         "./"
       ].join(" ")

    image_id = File.read(tmp_file.path).to_s.strip

    sh "docker tag #{image_id} ghcr.io/digital-identity-labs/#{container_name}:#{full_version}-plus"
    sh "docker tag #{image_id} ghcr.io/digital-identity-labs/#{container_name}:#{major_version}-plus"
    sh "docker tag #{image_id} ghcr.io/digital-identity-labs/#{container_name}:#{minor_version}-plus"
    sh "docker tag #{image_id} ghcr.io/digital-identity-labs/#{container_name}:latest-plus"
    sh "docker tag #{image_id} #{snapshot_name}-plus"

  end

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

desc "Build the image, run, and open a shell"
task :shell => [:build] do
  sh "docker run -d -p 8080:8080 #{snapshot_name}"
  container_id = `docker ps -q -l`.chomp
  sh "docker exec -it #{container_id} /bin/bash"
end

desc "Build and run the image and then export configuration files"
task :export => [:build] do
  sh "docker run -d -p 8080:8080 #{snapshot_name}"
  container_id = `docker ps -q -l`.chomp
  sh "mkdir -p exported_optfs/"
  sh "docker cp #{container_id}:/opt/shibboleth-idp/ exported_optfs/shibboleth-idp"
  sh "docker cp #{container_id}:/opt/jetty-shib/ exported_optfs/jetty-shib"
  sh "docker stop #{container_id}"
end

desc "Build and publish all Docker images to Github"
task publish: ["build:all"] do

  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:#{full_version}-base"
  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:#{major_version}-base"
  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:#{minor_version}-base"
  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:latest-base"
  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:#{full_version}-plus"
  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:#{major_version}-plus"
  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:#{minor_version}-plus"
  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:latest-plus"
  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:#{full_version}"
  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:#{major_version}"
  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:#{minor_version}"
  sh "docker image push ghcr.io/digital-identity-labs/#{container_name}:latest"
  sh "docker image push digitalidentity/#{container_name}:#{full_version}"
  sh "docker image push digitalidentity/#{container_name}:latest"
end

task :force_reset do
  ENV["ISHIGAKI_FORCE_REBUILD"] = "yes"
end

