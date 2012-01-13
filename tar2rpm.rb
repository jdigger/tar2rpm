include FileUtils

module Tar2Rpm

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


  class BuildRpm

    DEFAULT_PREFIX = '/opt'
    DEFAULT_ARCH = 'noarch'

    attr_reader :top_dir, :tar, :tar_filename, :version, :name, :arch, :files, :description, :summary, :prefix

    def initialize(p)
      self.top_dir = p[:top_dir]
      self.tar = p[:tar]
      @tar_filename = File.basename(@tar.filename)
      @version = p[:version] ? p[:version] : @tar.version
      @name = p[:name] ? p[:name] : @tar.basename
      @arch = p[:arch] ? p[:arch] : DEFAULT_ARCH
      @prefix = p[:prefix] ? p[:prefix] : DEFAULT_PREFIX
      @description = p[:description] ? p[:description] : ''
      @summary = p[:summary] ? p[:summary] : ''
      if (p[:files]) then
        @files = p[:files]
      else
        @files = @tar.tar_content_filenames
      end
    end


    def tar=(tar)
      raise ArgumentError.new("Missing tar") unless tar
      raise ArgumentError.new(":tar has to be a Tar2Rpm::Tar") unless tar.is_a? Tar2Rpm::Tar
      @tar = tar
    end


    def top_dir=(top_dir)
      raise ArgumentError.new('Need a top_dir') unless top_dir
      @top_dir = top_dir
    end


    def create_build()
      create_build_area()
      copy_tar_file()
      create_spec_file("#{top_dir}/SPECS/#{name}.spec")
    end


    def create_spec_file(filename)
      File.open(filename, 'w') do |file|
        file.puts <<EOF
%define _topdir     /tmp/tar2rpm
%define _tmppath    %{_topdir}/TMP
%define _target_cpu #{arch}
%define _target_os  linux
%define name        #{name}
%define version     #{version}
%define release     1
%define buildroot   %{_topdir}/%{name}-%{version}-buildroot

Name: %{name}
Version: %{version}
Release: %{release}
Vendor: Canoe Ventures, LLC
Summary: #{summary}
Source0: #{tar_filename}
Prefix: #{prefix}
Group: Misc
License: Unknown
BuildRoot: %{buildroot}
BuildArch: %{_target_cpu}

%description
#{description}

%prep
%setup -c -n %{name}-%{version}

%build

%install
[ -d ${RPM_BUILD_ROOT} ] && rm -rf ${RPM_BUILD_ROOT}
/bin/mkdir -p ${RPM_BUILD_ROOT}#{prefix}
/bin/cp -vR ${RPM_BUILD_DIR}/%{name}-%{version}/* ${RPM_BUILD_ROOT}#{prefix}/

%clean

%files
%defattr(-,root,root)
#{convert_filenames_to_rpm(files)}
EOF
      end
    end


    private

    def create_build_area()
      rm_rf(top_dir)
      FileUtils.mkdir_p(["#{top_dir}/BUILD", "#{top_dir}/RPMS", "#{top_dir}/SOURCES",
        "#{top_dir}/SPECS", "#{top_dir}/SRPMS"])
    end


    def convert_filenames_to_rpm(filenames)
      filenames.map {|file| file.start_with?(prefix) ? file : file.insert(0, prefix+'/')}.join("\n")
    end


    def copy_tar_file()
      FileUtils.copy_file(tar.filename, "#{top_dir}/SOURCES/#{tar_filename}")
    end

  end

end
