#
control "jetty_does_not_send_version_header" do
  impact 1.0
  title "Jetty does not send version header"
  desc "Jetty does not send software version information in a header (don't advertise vulnerabilities)"

  describe http('http://localhost:8080/idp/status') do
    #its('headers') { should_not include 'server' }
    its('headers.server') { should eq nil }
  end

end