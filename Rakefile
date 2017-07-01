
task :default => :refresh

task :refresh => [:build, :test]

task :build do
  sh "docker build --pull -t digitalidentitylabs/ishigaku:snapshot ."
end

task :rebuild do
  sh "docker build --pull --force-rm -t digitalidentitylabs/ishigaku:snapshot ."
end

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

task :push do

  branch = (ENV['TRAVIS_BRANCH'] || `git symbolic-ref --short HEAD`).to_s.downcase.chomp
  repo = "digitalidentity/ishigaki"
  tag  = (branch == "master" ? "latest" : (branch || "snapshot")).to_s.chomp

  if ["develop", "snapshot"].include?(branch)
    puts "Not pushing: Can push to Docker Hub only from master or stable release tags"
    exit 1
  end

  puts "Building, testing and pushing to Docker Hub from #{branch} branch"
  sh "docker build -f Dockerfile -t #{repo}:#{tag} ."
  sh "docker push #{repo}"

end

