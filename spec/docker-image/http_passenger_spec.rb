require "rest-client"

RSpec.describe "HTTP/Passenger" do
  let(:host) do
    ENV.fetch("TEST_HOST", "localhost:3080")
  end
  describe "/" do
    it "returns 200" do
      response = RestClient::Request.execute(
        method: :post,
        url: host,
        payload: JSON.generate(
          rawPath: "/api/v1/cura/convert",
          body: Base64.encode64(JSON.generate(
                                  job_id: "testJobId",
                                  input_path: stl_file,
                                  printer_code_name: "zortrax_m200_plus",
                                  output_path: "test/testJobId.gcode",
                                  cura_config_version: "v1",
                                  cura_args: cura_args
                                )),
          isBase64Encoded: true
        ),
        timeout: 120
      )

      expect(response.code).to eq(200)
      puts response.body
      response = JSON.parse(response.body)
      expect(response["statusCode"]).to eq(200), response["body"]
      expect(response["headers"]).to eq({ "Content-Type" => "application/json" })

      response_body = JSON.parse(response["body"])
      expect(response_body["output"]).to eq("test/testJobId.gcode")
      expect(response_body["size"] > 150_000).to eq(true)
      expect(response_body["signed_url"]).not_to be_nil

      response = RestClient.get(response_body["signed_url"])
      File.binwrite("#{test_dir}/cube.gcode", response.body)
    end
  end

  describe "non / path" do
    xit "returns 200 too" do
    end
  end

  describe "friendly error pages" do
  end

  describe "custom 404.html page" do
  end

  describe "custom 500.html page" do
  end
end
