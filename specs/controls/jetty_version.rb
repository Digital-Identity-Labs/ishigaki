control "jetty_version" do
  impact 1.0
  title "The latest stable Jetty should be installed"
  desc "The latest stable Jetty server should have been downloaded and installed"

  describe file('/opt/jetty') do
    it { should be_directory }
  end

  describe file('/opt/jetty/start.jar') do
    it { should exist }
  end

  describe command('cat /opt/jetty/VERSION.txt | head -n1') do
    its('stdout') { should eq "jetty-11.0.17 - 09 October 2023\n" }
  end

  describe os_env('JETTY_HOME') do
    its('content') { should eq "/opt/jetty" }
  end

end
