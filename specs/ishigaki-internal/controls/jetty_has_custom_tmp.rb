control "jetty_has_custom_tmp" do
  impact 1.0
  title "Jetty uses a dedicated tmp directory"
  desc "Jetty uses a dedicated tmp for Shibboleth IdP, to avoid /tmp tidying causing problems"

  describe file('/var/opt/jetty/tmp') do
    it { should be_directory }
    its('owner') { should eq 'jetty' }
    its('mode') { should cmp '0755' }
    it { should be_writable.by  'owner' }
  end

  describe file('/opt/jetty-shib/start.ini') do
    its('content') { should include "-Djava.io.tmpdir=/var/opt/jetty/tmp"}
  end

  describe command('ps -aux | grep  /usr/lib/jvm/zulu-8-amd64/jre/bin/java') do
    its('stdout') { should include "-Djava.io.tmpdir=/var/opt/jetty/tmp" }
  end


end