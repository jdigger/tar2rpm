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
