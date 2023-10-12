control "jetty_on_port_8080" do
  impact 1.0
  title "IdP is available on port 8080, as HTTP and H2c"
  desc "Run IdP in Jetty as a non-root user"

  describe port(8080) do
    it {should be_listening}
    its('protocols') {should include 'tcp'}
    # its('processes') {should include 'java'} # For some reason using Gosu causes PID to be anon # TODO / FIX
  end

  describe ssl(host: "0.0.0.0", port: 8080) do
    it { should_not be_enabled }
  end

end