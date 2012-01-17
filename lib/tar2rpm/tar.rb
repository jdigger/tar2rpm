module Tar2Rpm

  # This class represents a TAR/TGZ file.
  # (Currently only works for GZipped TAR files.)
  #
  # This knows how to:
  # * list the files in the tar
  # * extract the contents to a directory
  # * extract the "package" name and version from the tar file name
  #
  class Tar
    attr_reader :filename, :basename, :version


    def initialize(filename)
      self.filename = filename
    end


    def extract_tar(target_dirname)
      Dir.chdir(target_dirname) do
        `tar xzf #{filename}`
      end
    end


    # Returns the files inside the tar as an array.
    def tar_content_filenames
       `tar tzf #{filename}`.split("\n")
    end


    def filename=(filename)
      raise FileNotFoundError.new(filename) unless File.exists?(filename)
      raise FilenameParsingError.new("This does not appear to be a TAR: #{filename}") unless filename =~ /\.(tar\.gz|tgz)$/
      raise FilenameParsingError.new("This does not appear to have a version in the name: #{filename}") unless filename =~ /-\d.*\.(tar\.gz|tgz)$/

      @filename = filename

      # extract the pieces from the name
      /^(?<bn>.*)-(?<ver>\d.*?)\.(tar\.gz|tar|tgz)$/ =~ File.basename(filename)
      @basename, @version = bn, ver
    end


    class FileNotFoundError < RuntimeError
    end

    class FilenameParsingError < RuntimeError
    end

  end

end
