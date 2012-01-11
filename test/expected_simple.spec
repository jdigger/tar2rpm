%define _topdir    /var/tmp
%define name       simple
%define version    3.4
%define release    1
%define buildroot  %{_topdir}/%{name}-%{version}-buildroot

Name: %{name}
Version: %{version}
Release: %{release}
Vendor: Canoe Ventures, LLC
Summary: A simple example
Source0: simple.tar
BuildRoot: %{buildroot}
BuildArch: x86_64

%description
A simple description.

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
/file1.txt
/file2.txt
