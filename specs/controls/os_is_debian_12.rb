control "os_is_debian_12" do
  impact 1.0
  title "OS is Debian 12 (Bookworm)"
  desc "The operating system is Debian 12 (Bookworm) - probably MiniDeb"

  describe file('/etc/issue.net') do
    its('content') { should eq "Debian GNU/Linux 12\n" }
  end

end
