control "jetty_logs_to_stdout" do
  impact 1.0
  title "Jetty logs messages to stdout, to be collected by Docker"
  desc "By default Jetty should log to stdout, but log directory should be available on image"

  describe file('/opt/jetty-shib/logs') do
    it { should be_directory }
    its('owner') { should eq 'root' }
    its('mode') { should cmp '0770' }
    it { should be_grouped_into 'jetty' }
    it { should be_writable.by  'jetty' }
  end

  describe file('/opt/jetty-shib/logs/*') do
    it { should_not exist }
  end
  describe command('ls -l /opt/jetty-shib/logs/* | grep log | wc -l | xargs echo -n') do
    its('stdout') { should eq "0" }
  end


end