# # encoding: utf-8
# # copyright: 2015, The Authors
# # license: All rights reserved
#
# title 'sample section'
#
# # you can also use plain tests
# describe file('/tmp') do
#   it { should be_directory }
# end
#
# # you add controls here
# control 'tmp-1.0' do                        # A unique ID for this control
#   impact 0.7                                # The criticality, if this control fails.
#   title 'Create /tmp directory'             # A human-readable title
#   desc 'An optional description...'
#   describe file('/tmp') do                  # The actual test
#     it { should be_directory }
#   end
# end
#
#
# control "misc-1.0" do # A unique ID for this control
#   impact 1.0 # Just how critical is
#   title "What's going on then?" # Readable by a human
#   desc "Just seeing if the actual stuff is stuffing" # Optional description
#
#   describe package('telnetd') do
#     it {should_not be_installed}
#   end
#
#   describe inetd_conf do
#     its("telnet") {should eq nil}
#   end
#
#   describe port(8080) do
#     it {should be_listening}
#     its('protocols') {should include 'tcp6'}
#     its('processes') {should include 'java'}
#   end
#
#
#   describe file('/opt/misc/Test.java') do
#     it {should exist}
#   end
#
#
#   describe processes('java') do
#     its('users') {should_not include ['root']}
#   end
#
# end