
task :default => :refresh

task :refresh => [:build, :test]

task :build do
  sh "docker build ."
end

task :rebuild do
  sh "docker build --force-rm ."
end

task :test => [:build] do
  sh "echo hmm"
end
