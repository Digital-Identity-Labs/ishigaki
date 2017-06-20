control "java_crypto" do
  impact 1.0
  title "Java crypto licensing extension are installed"
  desc "Zulu and Oracle Java ship with nerfed crypto that can be unlocked with optional files"

  describe file('/opt/misc/Test.java') do
    it {should exist}
  end

  describe command('javac -d /tmp /opt/misc/Test.java && java -cp /tmp Test && rm /tmp/Test.class') do
    its('stdout') { should include 'AES with 128-bit key OK' }
    its('stdout') { should include 'AES with 256-bit key OK' }
    its('stdout') { should include 'SHA-256 algorithm is present' }
    its('exit_status') { should eq 0 }
  end

end