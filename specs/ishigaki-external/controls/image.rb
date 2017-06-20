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



describe docker_image('alpine:latest') do
  it { should exist }
  its('id') { should eq 'sha256:4a415e3663882fbc554ee830889c68a33b3585503892cc718a4698e91ef2a526' }
  its('image') { should eq 'alpine:latest' }
  its('repo') { should eq 'alpine' }
  its('tag') { should eq 'latest' }
end