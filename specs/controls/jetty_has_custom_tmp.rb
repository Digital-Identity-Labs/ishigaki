control "jetty_has_custom_tmp" do
  impact 1.0
  title "Jetty uses a dedicated tmp directory"
  desc "Jetty uses a dedicated tmp for Shibboleth IdP, to avoid /tmp tidying causing problems"

  describe file('/opt/jetty-shib/tmp') do
    it { should be_directory }
    its('owner') { should eq 'jetty' }
    its('mode') { should cmp '0770' }
    it { should be_writable.by  'owner' }
  end

  describe file('/opt/jetty-shib/start.d/start.ini') do
    its('content') { should include "-Djava.io.tmpdir=/opt/jetty-shib/tmp"}
  end

  describe command('ps -aux | grep /usr/lib/jvm/java') do
    its('stdout') { should include "-Djava.io.tmpdir=/opt/jetty-shib/tmp" }
  end


end
