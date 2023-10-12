control "os_is_debian_11" do
  impact 1.0
  title "OS is Debian 11 (Buster)"
  desc "The operating system is Debian 11 (Bullseye) - probably MiniDeb"

  describe file('/etc/issue.net') do
    its('content') { should eq "Debian GNU/Linux 11\n" }
  end

end
