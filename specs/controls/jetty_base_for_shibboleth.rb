control "jetty_base_for_shibboleth" do
  impact 1.0
  title "A customised instance of Jetty for Shibboleth IdP"
  desc "An instance of Jetty should be configured to run the Shibboleth IdP"

  describe file('/opt/jetty-shib') do
    it { should be_directory }
  end

  describe os_env('JETTY_BASE') do
    its('content') { should eq "/opt/jetty-shib" }
  end

end