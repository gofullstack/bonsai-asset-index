class UnfollowExtensionWorker < ApplicationWorker

  def perform(extension_id, user_id)
    extension = Extension.find(extension_id)
    user = User.find(user_id)
    user.octokit.unstar(extension.github_repo)
  end
end
