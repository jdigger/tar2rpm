include FileUtils

module Tar2Rpm

  class Tar
    attr_reader :filename


    def initialize(filename)
      raise "File does not exist at #{filename}" unless File.exists?(filename)
      @filename = filename
    end


    def extract_tar(target_dirname)
      Dir.chdir(target_dirname) do
        `tar xf #{filename}`
      end
    end


    def tar_content_filenames
       `tar tf #{filename}`.split("\n")
    end
  end


  class BuildRpm
    
    attr_reader :top_dir, :tar, :tar_filename, :version, :name, :arch, :files, :description, :summary

    def initialize(p)
      self.top_dir = p[:top_dir]
      self.tar = p[:tar]
      @tar_filename = File.basename(@tar.filename)
      self.version = p[:version]
      @name = p[:name] ? p[:name] : tar_filename.sub(/^(.*)\.(tar|tgz|tar\.gz)/, '\1')
      @arch = p[:arch] ? p[:arch] : 'noarch'
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


    def version=(version)
      raise ArgumentError.new('Need a version') unless version
      @version = version
    end


    def create_build()
      create_build_area()
      copy_tar_file()
      create_spec_file("#{top_dir}/SPECS/#{name}.spec")
    end


    def create_spec_file(filename)
      File.open(filename, 'w') do |file|
        file.puts <<EOF
%define _topdir    /var/tmp
%define name       #{name}
%define version    #{version}
%define release    1
%define buildroot  %{_topdir}/%{name}-%{version}-buildroot

Name: %{name}
Version: %{version}
Release: %{release}
Vendor: Canoe Ventures, LLC
Summary: #{summary}
Source0: #{tar_filename}
BuildRoot: %{buildroot}
BuildArch: #{arch}

%description
#{description}

%prep
%setup -c -n %{name}-%{version}

%build

%install
[ -d ${RPM_BUILD_ROOT} ] && rm -rf ${RPM_BUILD_ROOT}
/bin/mkdir -p ${RPM_BUILD_ROOT}
/bin/cp -axv ${RPM_BUILD_DIR}/%{name}-%{version}/* ${RPM_BUILD_ROOT}/

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
      filenames.map {|file| file.start_with?('/') ? file : file.insert(0, '/')}.join("\n")
    end


    def copy_tar_file()
      FileUtils.copy_file(tar.filename, "#{top_dir}/SOURCES/#{tar_filename}")
    end

  end

end
