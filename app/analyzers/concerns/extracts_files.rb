require 'active_support/concern'

module ExtractsFiles
  extend ActiveSupport::Concern

  private

  def extract_readme(files:, path_method:, file_reader:)
    full_paths       = files.map(&path_method)
    readme_paths     = full_paths.grep /\/readme/i
    best_readme_path = readme_paths.sort_by { |path| [path.split('/').size, File.basename(path).size] }.first

    # Don't go deeper than one level down, e.g. foo/readme is fine, but foo/down/readme is not.
    return [nil, nil] if best_readme_path.split('/').size > 2

    content   = file_reader.call(files, best_readme_path).presence
    extension = File.extname(best_readme_path).to_s.sub(/\A\./, '').presence  # strip off any leading '.'
    return [content, extension]
  end

  def extract_file(file_path:, files:, path_method:, file_reader:)
    full_paths     = files.map(&path_method)
    regexp         = file_path.is_a?(Regexp) ? file_path : /#{file_path}\z/
    matching_paths = full_paths.grep regexp
    best_path      = matching_paths.sort_by { |path| [path.split('/').size, File.basename(path).size] }.first

    # Don't go deeper than one level down, e.g. foo/<file_path> is fine, but foo/down/<file_path> is not.
    split_file_path = file_path.to_s.split('/')
    # Handle Regexps that begin with /, e.g. /\/readme/i
    split_file_path.shift if file_path.is_a?(Regexp) && split_file_path.first =~ /\\\z/
    return [nil, nil] if best_path.split('/').size > split_file_path.size + 1

    content = file_reader.call(files, best_path).presence
    return content, best_path
  end
end
