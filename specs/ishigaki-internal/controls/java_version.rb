control "java_version" do
  impact 1.0
  title "Zulu Java is installed correctly"
  desc "Default OpenJDK Java should not be used: either Zulu or Oracle Java should be installed"

  describe apt('http://repos.azulsystems.com/debian') do
    it { should exist }
    it { should be_enabled }
  end

  describe package('zulu-8') do
    it { should be_installed }
    its('version') { should >= '8.21.0.1' }
  end

  describe file('/usr/lib/jvm/zulu-8-amd64') do
    it {should exist}
  end

  describe package('openjdk-8-jdk') do
    it { should_not be_installed }
  end

  describe os_env('JAVA_HOME') do
    its('content') { should eq "/usr/lib/jvm/zulu-8-amd64" }
  end

  describe command('java -version') do
    its('stderr') { should include 'openjdk version "1.8.0' }
    its('stderr') { should include 'Zulu' }
    its('stderr') { should include 'OpenJDK 64-Bit Server VM' }
    its('exit_status') { should eq 0 }
  end

end