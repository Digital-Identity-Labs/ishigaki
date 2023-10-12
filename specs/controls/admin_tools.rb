control "admin_tools" do
  impact 1.0
  title "A directory for admin scripts is present"
  desc "A standard directory for admin tools should be present"

  describe file('/opt/admin') do
    it { should exist }
  end

  describe file('/opt/admin/prepare_apps.sh') do
    it { should_not exist }
  end

  describe os_env('ADMIN_HOME') do
    its('content') { should eq "/opt/admin" }
  end

end
