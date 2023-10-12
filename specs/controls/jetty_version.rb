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

  describe file('/opt/jetty/VERSION.txt') do
    its('content') { should match(%r{^jetty-10}) }
  end

  describe os_env('JETTY_HOME') do
    its('content') { should eq "/opt/jetty" }
  end

end
