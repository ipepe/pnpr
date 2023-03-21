
RSpec.describe "SSH/Capistrano" do
  let(:host) do
    ENV.fetch("TEST_HOST", "localhost")
  end
  let(:port) do
    ENV.fetch("TEST_SSH_PORT", "3022").to_i
  end
  describe "ssh" do
    it "has open ssh port" do
      expect(TCPSocket.new(host, port)).to be_a(TCPSocket)
    end
  end
  describe "capistrano" do
    it "deploys successfully" do
      expect(system("cd spec_rails_app && bundle exec cap spec deploy")).to eq(true)
    end
  end
end