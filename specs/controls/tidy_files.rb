control "tidy_files" do
  impact 1.0
  title "Unnecessary files are removed"
  desc "The image has had build files, excess packages and other cruft deleted"

  describe file('/usr/local/src') do
    it {should be_directory}
  end

  describe file('/usr/local/src/*') do
    it {should_not exist}
  end
  describe command('ls -l /usr/local/src/ | grep -v plugins | wc -l | grep -v plugins | xargs echo -n') do
    its('stdout') { should eq "1" }
  end

  describe file('/opt/jetty/demo-base') do
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
  describe command('ls -l /opt/shibboleth-idp/bin/ | grep \.bat | wc -l | xargs echo -n') do
    its('stdout') { should eq "0" }
  end

  %w[gpg dirmngr unzip].each do |deb|

    describe package(deb) do
      it { should_not be_installed }
    end

  end

  %w[src.zip demo man sample].each do |cruft|
    describe file("/usr/lib/jvm/zulu-8-amd64/#{cruft}") do
      it {should_not exist}
    end
  end

end