control "tidy_files" do
  impact 1.0
  title "Unnecessary files are removed"
  desc "The image has had build files, excess packages and other cruft deleted"

  describe file('/usr/local/src') do
    it {should be_directory}
    it {should be_empty}
  end

  describe file('/opt/jetty/demo_base') do
    it {should_not exist}
  end

  describe.one do

    describe file('/var/lib/apt/lists') do
      it {should_not exist}
    end

    describe file('/var/lib/apt/lists') do
      it {should be_empty}
    end

  end

  describe file('/opt/shibboleth-idp/bin/*.bat') do
    it {should_not exist}
  end

  describe file('/opt/jetty/start.jar') do
    it {should exist}
  end

  describe file('/opt/jetty/VERSION.txt') do
    its('content') {should match(%r{^jetty-9\.4\.})}
  end

  describe os_env('JETTY_HOME') do
    its('content') {should eq "/opt/jetty"}
  end


end