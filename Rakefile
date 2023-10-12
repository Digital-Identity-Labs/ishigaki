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

    if ENV["PUBLISH_MP_MODE"].to_s.downcase == "yes"
      command = "docker buildx build"
      platforms = "--platform linux/amd64,linux/arm64"
      push_or_not = "--push"
    else
      command = "docker build"
      platforms = ""
      push_or_not = " "
    end

    tags = [
      "ghcr.io/digital-identity-labs/#{container_name}:#{full_version}",
      "ghcr.io/digital-identity-labs/#{container_name}:#{major_version}",
      "ghcr.io/digital-identity-labs/#{container_name}:#{minor_version}",
      "ghcr.io/digital-identity-labs/#{container_name}:latest",
        "digitalidentity/#{container_name}:#{full_version}",
        "digitalidentity/#{container_name}:latest",
        "#{container_name}:snapshot",
    ].map { |t| " -t #{t}" }.join(" ")

    sh [
         command,
         "--iidfile #{tmp_file.path}",
         platforms,
         "--label 'version=#{full_version}'",
         "--label 'org.opencontainers.image.revision=#{git_hash}'",
         "--progress=plain",
         tags,
         rebuild_or_not,
         push_or_not,
         "./"
       ].join(" ")

    image_id = File.read(tmp_file.path).to_s.strip
    puts image_id

  end

  desc "Build the Docker image for use a base image"
  task :base do

    tmp_file = Tempfile.new("docker")
    git_hash = `git rev-parse --short HEAD`

    rebuild_or_not = ENV["ISHIGAKI_FORCE_REBUILD"] ? "--pull --force-rm" : ""

    if ENV["PUBLISH_MP_MODE"].to_s.downcase == "yes"
      command = "docker buildx build"
      platforms = "--platform linux/amd64,linux/arm64"
      push_or_not = "--push"
    else
      command = "docker build"
      platforms = ""
      push_or_not = " "
    end

    tags = [
      "ghcr.io/digital-identity-labs/#{container_name}:#{full_version}-base",
      "ghcr.io/digital-identity-labs/#{container_name}:#{major_version}-base",
      "ghcr.io/digital-identity-labs/#{container_name}:#{minor_version}-base",
      "ghcr.io/digital-identity-labs/#{container_name}:latest-base",
    ].map { |t| " -t #{t}" }.join(" ")

    sh [
         command,
         "--iidfile #{tmp_file.path}",
         platforms,
         "--build-arg WRITE_MD=0",
         "--build-arg EDWIN_STARR=1",
         "--build-arg DELAY_WAR=1",
         "--build-arg MODULES=''",
         "--build-arg PLUGINS=''",
         "--label 'version=#{full_version}'",
         "--label 'org.opencontainers.image.revision=#{git_hash}'",
         "--progress=plain",
         tags,
         rebuild_or_not,
         push_or_not,
         "./"
       ].join(" ")

    image_id = File.read(tmp_file.path).to_s.strip
    puts image_id

  end

  desc "Build the Docker image (including extra plugins)"
  task :plus do

    tmp_file = Tempfile.new("docker")
    git_hash = `git rev-parse --short HEAD`

    rebuild_or_not = ENV["ISHIGAKI_FORCE_REBUILD"] ? "--pull --force-rm" : ""

    if ENV["PUBLISH_MP_MODE"].to_s.downcase == "yes"
      command = "docker buildx build"
      platforms = "--platform linux/amd64,linux/arm64"
      push_or_not = "--push"
    else
      command = "docker build"
      platforms = ""
      push_or_not = " "
    end

    plugin_ids = [
      "net.shibboleth.idp.plugin.metadatagen",
      "net.shibboleth.idp.plugin.authn.totp",
      "net.shibboleth.oidc.common",
      "net.shibboleth.idp.plugin.oidc.config",
      "net.shibboleth.idp.plugin.oidc.op",
      "net.shibboleth.idp.plugin.oidc.rp",
      "net.shibboleth.idp.plugin.authn.duo.sdk",
      "net.shibboleth.idp.plugin.nashorn"
    ].join(" ")

    tags = [
      "ghcr.io/digital-identity-labs/#{container_name}:#{full_version}-plus",
      "ghcr.io/digital-identity-labs/#{container_name}:#{major_version}-plus",
      "ghcr.io/digital-identity-labs/#{container_name}:#{minor_version}-plus",
      "ghcr.io/digital-identity-labs/#{container_name}:latest-plus",
    ].map { |t| " -t #{t}" }.join(" ")

    sh [
         command,
         "--iidfile #{tmp_file.path}",
         platforms,
         "--build-arg WRITE_MD=0",
         "--build-arg DELAY_WAR=1",
         "--build-arg MODULES=''",
         "--build-arg PLUGIN_IDS='#{plugin_ids}'",
         "--build-arg PLUGIN_MODULES=''",
         "--label 'version=#{full_version}'",
         "--label 'org.opencontainers.image.revision=#{git_hash}'",
         "--progress=plain",
         tags,
         rebuild_or_not,
         push_or_not,
         "./"
       ].join(" ")

    image_id = File.read(tmp_file.path).to_s.strip
    puts image_id

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
    sh "bundle exec cinc-auditor exec specs/ #{colour} -t docker://#{container_id} "
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
task publish: [:publish_mp_mode, "build:all"] do
  puts "Complete!"
end

task :force_reset do
  ENV["ISHIGAKI_FORCE_REBUILD"] = "yes"
end

task :publish_mp_mode do
  ENV["PUBLISH_MP_MODE"] = "yes"
end
