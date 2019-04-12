json.type        "Asset"
json.api_version "core/v2"

json.metadata do
  json.name        @release_asset.extension_name
  json.namespace   @release_asset.extension_namespace
  #json.labels      @release_asset.labels.to_h
  json.version     @release_asset.version
  json.annotations @release_asset.annotations.to_h
end

json.spec do
  json.url     					@release_asset.github_asset_url
  json.sha512  					@release_asset.github_asset_sha
  json.s3_url  					@release_asset.s3_url
  json.s3_last_modified @release_asset.s3_last_modified
  #json.filters Array.wrap(@release_asset.filter)
end
