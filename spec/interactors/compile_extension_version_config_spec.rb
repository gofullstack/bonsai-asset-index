require "spec_helper"

describe CompileExtensionVersionConfig do
  let(:version_name) { "1.2.2"}
  let(:config)       { {"builds"=>
                          [{"arch"=>"x86_64",
                            "filter"=>
                              ["System.OS == linux",
                               "(System.Arch == x86_64) || (System.Arch == amd64)"],
                            "platform"=>"linux",
                            "sha_filename"=>"test_asset-\#{version}-linux-x86_64.sha512.txt",
                            "asset_filename"=>"test_asset-\#{version}-linux-x86_64.tar.gz"}]} }
  let(:version)      { create :extension_version, config: config, version: version_name }
  subject(:context)  { CompileExtensionVersionConfig.call(version: version) }

  describe ".call" do
    let(:asset_hash1)        { {name: "test_asset-1.2.2-linux-x86_64.tar.gz",
                                browser_download_url: "https://example.com/download"} }
    let(:asset_hash2)        { {name: "test_asset-1.2.2-linux-x86_64.sha512.txt",
                                browser_download_url: "https://example.com/sha_download"} }
    let(:release_data)       { {tag_name: version.version, assets: [asset_hash1, asset_hash2]} }
    let(:expected_data_hash) { {"builds" =>
                                  [{"arch"           => "x86_64",
                                    "filter"         =>
                                      ["System.OS == linux",
                                       "(System.Arch == x86_64) || (System.Arch == amd64)"],
                                    "platform"       => "linux",
                                    "sha_filename"   => "test_asset-\#{version}-linux-x86_64.sha512.txt",
                                    "asset_filename" => "test_asset-\#{version}-linux-x86_64.tar.gz",
                                    "asset_url"      => "https://example.com/download",
                                    "asset_sha"      => "c1ec2f493f0ff9d83914c1ec2f493f0ff9d83914"}]} }

    before do
      allow_any_instance_of(Octokit::Client  ).to receive(:releases) { [release_data] }
      allow_any_instance_of(Faraday::Response).to receive(:success?) { true }
      allow_any_instance_of(Faraday::Response).to receive(:body)     { "c1ec2f493f0ff9d83914c1ec2f493f0ff9d83914" }
    end

    it "succeeds" do
      expect(context).to be_a_success
    end

    it "complies the configuration" do
      expect(context.data_hash).to eql(expected_data_hash)
    end
  end
end
