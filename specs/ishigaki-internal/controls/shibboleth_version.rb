control "shibboleth_version" do
  impact 1.0
  title "The latest stable Shibboleth IdP should be installed"
  desc "The latest stable Shibboleth IdP server should have been downloaded and installed"

  describe file('/opt/shibboleth-idp') do
    it { should be_directory }
  end

  describe file('/opt/shibboleth-idp/war/idp.war') do
    it { should exist }
  end

  describe os_env('IDP_HOME') do
    its('content') { should eq "/opt/shibboleth-idp" }
  end

end