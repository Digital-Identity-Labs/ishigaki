control "shibboleth_idp_service_is_running" do
  impact 1.0
  title "The Shibboleth IdP service is running"
  desc "The Shibboleth IdP service is running on this container"

  describe http('http://localhost:8080/idp/status') do
    its('status') { should cmp 200 }
    its('body') { should include 'idp_version: 3.' }
  end

end