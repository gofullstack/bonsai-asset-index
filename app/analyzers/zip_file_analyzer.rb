# An ActiveStorage analyzer that extracts any README content from the .zip file.
# See the documentation for the base +ActiveStorage::Analyzer+ class.

require 'zip'

class ZipFileAnalyzer < ActiveStorage::Analyzer
  include HasArchiveMetadata
  include ExtractsFiles

  MIME_TYPES = %w[
    application/zip
    application/octet-stream
    application/x-zip-compressed
    multipart/x-zip
  ]

  def self.accept?(blob)
    MIME_TYPES.include? blob.content_type.to_s
  end

  def with_file_finder(&block)
    download_blob_to_tempfile do |file|
      Zip::File.open(file.path.to_s) do |files|
        finder = FileFinder.new(files:       files,
                                path_method: :name,
                                reader:      self.method(:zipped_file_reader))
        return yield(finder)
      end
    end
  rescue
    #:nocov:
    return nil
    #:nocov:
  end

  private

  def zipped_file_reader(files, file_path)
    entry = files.find_entry(file_path)
    entry.get_input_stream.read
  end
end
