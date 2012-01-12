class Tar2Rpm

  def extract_tar(tarfile_name, target_dirname)
    Dir.chdir(target_dirname) do
     `tar xf #{tarfile_name}`
    end
  end


  def tar_content_filenames(tarfile_name)
     str = `tar tf #{tarfile_name}`
     str.split("\n")
  end
  
  
  def convert_filenames_to_rpm(filenames)
    filenames.map {|file| file.start_with?('/') ? file : file.insert(0, '/')}.join("\n")
  end


  def create_spec_file(file, args)
    raise "Need to supply :tar_filename" unless (args[:tar_filename])
    raise "Need to supply :version" unless (args[:version])

    args[:name] = args[:tar_filename].sub(/^(.*)\.(tar|tgz|tar\.gz)/, '\1') unless (args[:name])
    args[:arch] = 'noarch' unless (args[:arch])
    
    unless (args[:files]) then
      raise "Could not find '#{args[:tar_filename]}' in '#{Dir.pwd}' to extract file names from for :files." unless File.exists?(args[:tar_filename])
      args[:files] = tar_content_filenames(args[:tar_filename])
    end

    file.puts <<EOF
%define _topdir    /var/tmp
%define name       #{args[:name]}
%define version    #{args[:version]}
%define release    1
%define buildroot  %{_topdir}/%{name}-%{version}-buildroot

Name: %{name}
Version: %{version}
Release: %{release}
Vendor: Canoe Ventures, LLC
Summary: #{args[:summary]}
Source0: #{args[:tar_filename]}
BuildRoot: %{buildroot}
BuildArch: #{args[:arch]}

%description
#{args[:description]}

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
#{convert_filenames_to_rpm(args[:files])}
EOF
  end

end
