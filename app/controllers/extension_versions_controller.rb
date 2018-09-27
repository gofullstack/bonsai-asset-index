class ExtensionVersionsController < ApplicationController
  before_action :set_extension_and_version
  before_action :authenticate_user!, only: [:update_platforms]

  #
  # GET /extensions/:extension_id/versions/:version/download
  #
  # Redirects the user to the extension artifact
  #
  def download
    ExtensionVersion.increment_counter(:web_download_count, @version.id)
    Extension.increment_counter(:web_download_count, @extension.id)
    BonsaiAssetIndex::Metrics.increment('extension.downloads.web')
    DailyMetric.increment(@version.download_daily_metric_key)

    redirect_to helpers.download_url_for(@version)
  end

  #
  # GET /extensions/:extension_id/versions/:version
  #
  # Displays information about this particular extension version
  #
  def show
    @extension_versions = @extension.sorted_extension_versions
    @owner = @extension.owner
    @collaborators = @extension.collaborators
    @supported_platforms = @version.supported_platforms
    @owner_collaborator = Collaborator.new resourceable: @extension, user: @owner
    @downloads = DailyMetric.counts_since(@version.download_daily_metric_key, Date.today - 1.month)
    @commits = DailyMetric.counts_since(@extension.commit_daily_metric_key, Date.today - 1.year)
  end

  #
  # PUT /extension/:extension_id/versions/:version
  #
  # Updates the supported platforms for the extension version.
  #
  def update_platforms
    # TODO: Check auth and policy
    if policy(@extension).manage?
      params[:supported_platforms] ||= []
      @version.supported_platforms = SupportedPlatform.where(name: params[:supported_platforms])
      @version.save
    end

    redirect_to({ action: :show }.merge(params.slice(:username, :extension_id, :version)))
  end

  private

  def set_extension_and_version
    @extension = Extension.with_owner_and_lowercase_name(owner_name: params[:username], lowercase_name: params[:extension_id])
    @version = @extension.get_version!(params[:version])
  end
end
