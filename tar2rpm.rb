#puts RUBY_DESCRIPTION

TOP_DIR = '/tmp/rpm'
SOURCES_DIR = "#{TOP_DIR}/SOURCES"

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
  
  def create_spec_file(file, args)
    file.puts "Name: #{args[:name]}"
    file.puts "Version: #{args[:version]}"
    file.puts "Release: 1"
    file.puts "Vendor: Canoe Ventures, LLC"
    file.puts "Summary: #{args[:summary]}"
    file.puts "Source0: #{args[:tar_filename]}"
    file.puts "BuildRoot: /var/tmp/#{args[:name]}-buildroot"
    file.puts "BuildArch: #{args[:arch]}"
  end

end

# FILES=$(/bin/tar -tzf $1 | /bin/grep -v '^.*/$' | sed 's/^/\//')
# 
# /bin/cat > $OUTPUT << EOF
# Name: $NAME
# Version: $VERSION
# Release: $RELEASE
# Vendor: $VENDOR
# Summary: $SUMMARY
# License: $LICENSE
# Group: $GROUP
# Source0: %{name}-%{version}.tar.gz
# BuildRoot: /var/tmp/%{name}-buildroot
# BuildArch: $ARCH
# 
# %description
# $DESCRIPTION
# 
# %prep
# 
# %setup -c -n %{name}-%{version}
# 
# %build
# 
# %install
# [ -d \${RPM_BUILD_ROOT} ] && rm -rf \${RPM_BUILD_ROOT}
# /bin/mkdir -p \${RPM_BUILD_ROOT}
# /bin/cp -axv \${RPM_BUILD_DIR}/%{name}-%{version}/* \${RPM_BUILD_ROOT}/
# 
# 
# %post
# 
# %postun
# 
# %clean
# 
# %files
# %defattr(-,root,root)
# $FILES
# 
# %define date    %(echo \`LC_ALL="C" date +"%a %b %d %Y"\`)
# 
# %changelog
# 
# * %{date} User $EMAIL
# - first Version
# 
# EOF
# 
# echo "INFO: Spec file has been saved as '$OUTPUT':"
# echo "----------%<----------------------------------------------------------------------"
# /bin/cat $OUTPUT
# echo "----------%<----------------------------------------------------------------------"
