# encoding: utf-8
# copyright: 2015, The Authors
# license: All rights reserved

title 'sample section'

# you can also use plain tests
describe file('/tmp') do
  it { should be_directory }
end

# you add controls here
control 'tmp-1.0' do                        # A unique ID for this control
  impact 0.7                                # The criticality, if this control fails.
  title 'Create /tmp directory'             # A human-readable title
  desc 'An optional description...'
  describe file('/tmp') do                  # The actual test
    it { should be_directory }
  end
end


describe docker_container('some-postgres') do
  it { should exist }
  it { should be_running }
  its('repo') { should eq 'postgres' }
  its('ports') { should eq "0.0.0.0:5432->5432/tcp" }
  its('command') { should eq 'docker-entrypoint.sh postgres' }
end