control "jetty_runs_as" do
  impact 1.0
  title "Jetty/Shibboleth IdP does not run as root"
  desc "Run IdP in Jetty as a non-root user"

  describe group('jetty') do
    it { should exist }
  end

  describe user('jetty') do
    it { should exist }
    its('group') { should eq 'jetty' }
    its('groups') { should eq ['jetty']}
    its('home') { should eq '/opt/jetty-shib' }
    its('shell') { should eq '/bin/false' }
  end

   describe processes('java') do
     its('users') {should_not include ['root']}
   end

end