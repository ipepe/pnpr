RSpec.describe "Prometheus metrics" do
  let(:host) do
    ENV.fetch("TEST_HOST", "http://localhost:9149")
  end

  describe "GET /metrics" do
    it "returns 200" do
      response = RestClient.get("#{host}/metrics")
      expect(response.code).to eq(200)
      expect(response.headers[:content_type]).to eq("text/plain; version=0.0.4; charset=utf-8")
    end
  end
end
