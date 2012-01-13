%define _topdir     /tmp/tar2rpm
%define _tmppath    %{_topdir}/TMP
%define _target_cpu noarch
%define _target_os  linux
%define name        simple
%define version     3.4
%define release     1
%define buildroot   %{_topdir}/%{name}-%{version}-buildroot

Name: %{name}
Version: %{version}
Release: %{release}
Vendor: Canoe Ventures, LLC
Summary: A simple example
Source0: simple.tar.gz
Group: Misc
License: Unknown
BuildRoot: %{buildroot}
BuildArch: %{_target_cpu}

%description
A simple description.

%prep
%setup -c -n %{name}-%{version}

%build

%install
[ -d ${RPM_BUILD_ROOT} ] && rm -rf ${RPM_BUILD_ROOT}
/bin/mkdir -p ${RPM_BUILD_ROOT}
/bin/cp -vR ${RPM_BUILD_DIR}/%{name}-%{version}/* ${RPM_BUILD_ROOT}/

%clean

%files
%defattr(-,root,root)
/file1.txt
/file2.txt
