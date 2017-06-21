control "jetty_runs_as" do
  impact 1.0
  title "Jetty/Shibboleth IdP does not run as root"
  desc "Run IdP in Jetty as a non-root user"

   describe processes('java') do
     its('users') {should_not include ['root']}
   end

end