control "jetty_write_access_is_limited" do
  impact 1.0
  title "The jetty user/process can only change certain directories"
  desc "Prevent Jetty from changing it's own configuration in case it can be exploited"

  describe file('/opt/jetty') do
    it {should be_directory}
    its('owner') {should eq 'root'}
    its('group') {should eq 'root'}
    its('mode') {should cmp '0755'}
  end

  %w[bin etc lib modules start.jar].each do |dir|
    describe file("/opt/jetty/#{dir}") do
      its('owner') {should eq 'root'}
      its('group') {should eq 'root'}
      it { should_not be_writable.by_user('jetty') }
    end
  end

  %w[etc start.d webapps].each do |dir|
    describe file("/opt/jetty-shib/#{dir}") do
      its('owner') {should eq 'root'}
      its('group') {should eq 'root'}
      it { should_not be_writable.by_user('jetty') }
    end
  end

  describe file('/opt/jetty-shib/tmp') do
    it {should be_directory}
    its('owner') {should eq 'jetty'}
    it {should be_writable.by 'owner'}

  end

  describe file('/var/opt/shibboleth-idp/tmp') do
    it {should be_directory}
    its('owner') {should eq 'jetty'}
    it {should be_writable.by 'owner'}
  end

  %w[bin conf credentials dist doc edit-webapp flows messages views war].each do  |dir|
    describe file("/opt/shibboleth-idp/#{dir}") do
      it {should be_directory}
      its('owner') {should eq 'root'}
      its('group') {should eq 'root'}
      its('mode') {should cmp '0755'}
      it { should_not be_writable.by_user('jetty') }
    end
  end

  describe file('/opt/shibboleth-idp/metadata') do
    it {should be_directory}
    its('owner') {should eq 'jetty'}
    it {should be_writable.by 'owner'}
  end

  describe file('/opt/shibboleth-idp/logs') do
    it {should be_directory}
    its('owner') {should eq 'jetty'}
    it {should be_writable.by 'owner'}
  end


end
