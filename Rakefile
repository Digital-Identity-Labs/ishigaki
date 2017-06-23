
task :default => :refresh

task :refresh => [:build, :test]

task :build do
  sh "docker build --pull -t digitalidentitylabs/ishigaku ."
end

task :rebuild do
  sh "docker build --pull --force-rm -t digitalidentitylabs/ishigaku ."
end

task :test => [:build] do
  begin
    sh "docker run -d -p 8080:8080 digitalidentitylabs/ishigaku"
    container_id = `docker ps -q -l`
    sleep ENV['CI'] ? 20 : 10
    sh "bundle exec inspec exec specs/ishigaki-internal/  -t docker://#{container_id}"
  ensure
    sh "docker stop #{container_id}" if container_id
  end
end
