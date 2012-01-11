puts RUBY_DESCRIPTION

TOP_DIR = '/tmp/rpm'
SOURCES_DIR = "#{TOP_DIR}/SOURCES"

class Tar2Rpm

  def extract_tar(tarfile_name, target_dirname)
    Dir.chdir(target_dirname) do
     `tar xf #{tarfile_name}`
    end
  end

  def tar_content_filenames(tarfile_name)
     `tar tf #{tarfile_name}`
  end

end

# This script creates an RPM from a tar file.
# $1 : tar file

# NAME=$(echo ${1%%-*} | sed 's/^.*\///')
# VERSION=$(echo ${1##*-} | sed 's/[^0-9]*$//')
# RELEASE=0
# VENDOR="Reiner Rottmann"
# EMAIL="<rei..rATrottmann.it>"
# SUMMARY="Summary"
# LICENSE="GPL"
# GROUP="System"
# ARCH="noarch"
# DESCRIPTION="
# Longer
# ...
# Description
# "
# 
# ######################################################
# # users should not change the script below this line.#
# ######################################################
# 
# # This function prints the usage help and exits the program.
# usage(){
#     /bin/cat << USAGE
# 
# This script has been released under BSD license. Copyright (C) 2010 Reiner Rottmann <rei..rATrottmann.it>
# 
# $0 creates a simple RPM spec file from the contents of a tarball. The output may be used as starting point to create more complex RPM spec files.
# The contents of the tarball should reflect the final directory structure where you want your files to be deployed. As the name and version get parsed
# from the tarball filename, it has to follow the naming convention "<name>-<ver.si.on>.tar.gz". The name may only contain characters from the range
# [A-Z] and [a-z]. The version string may only include numbers seperated by dots.
# 
# Usage: $0  [TARBALL]
# 
# Example:
#   $ $0 sample-1.0.0.tar.gz
#   
#   $ /usr/bin/rpmbuild -ba /tmp/sample-1.0.0.spec 
# 
# USAGE
#     exit 1    
# }
# 
# if echo "${1##*/}" | sed 's/[^0-9]*$//' | /bin/grep -q  '^[a-zA-Z]\+-[0-9.]\+$'; then
#    if /usr/bin/file -ib "$1" | /bin/grep -q "application/x-gzip"; then
#       echo "INFO: Valid input file '$1' detected."
#    else
#       usage
#    fi
# else
#     usage
# fi
# 
# OUTPUT=/tmp/${NAME}-${VERSION}.spec
# 
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
