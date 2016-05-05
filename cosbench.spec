#
# spec file for package cosbench
#
# Copyright (c) 2016 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

Name:         cosbench
Summary:      Cloud Object Storage Benchmark
Version:      0.4.1
Release:      1
License:      Apache-2.0
Group:        Productivity/Networking/Email/Clients
URL:          https://github.com/intel-cloud/cosbench
Source:       cosbench-%{version}.tar.xz
BuildRoot:    %{_tmppath}/%{name}-%{version}-build
BuildRequires:update-alternatives
BuildRequires:java-devel >= 1.6.0
BuildRequires:ant
Requires:     java >= 1.6.0
BuildArch:    noarch

%description
COSBench is a benchmarking tool to measure the performance of Cloud Object
Storage services. Object storage is an emerging technology that is different
from traditional file systems (e.g., NFS) or block device systems (e.g.,
iSCSI). Amazon S3 and Openstack* swift are well-known object storage solutions.

COSBench now supports OpenStack* Swift, Amazon* S3, Amplidata v2.3, 2.5 and
3.1, Scality, Ceph, CDMI, Google Cloud Storage, as well as custom adaptors.

%prep
%setup -qn cosbench-%{version}

%build
%ant compile-all

%install
%ant install -Dinst.bin.dir="%buildroot/%_bindir" \
    -Dinst.lib.dir="%buildroot/%_datadir/%name" \
    -Dinst.conf.dir="%buildroot/%_sysconfdir/%name" \
    -Dinst.run.dir="\\\$HOME/.%name"

%files
%defattr(-,root,root)
%doc AUTHORS CHANGELOG LICENSE NOTICE README.md
%_bindir/%name-cli.sh
%_bindir/%name-stop-controller.sh
%_bindir/%name-stop-driver.sh
%_bindir/%name-stop-all.sh
%_bindir/%name-start-all.sh
%_bindir/%name-start-driver.sh
%_bindir/%name-stop.sh
%_bindir/%name-start.sh
%_bindir/%name-start-controller.sh
%_datadir/cosbench
%config %dir %_sysconfdir/%name
%config(noreplace) %_sysconfdir/%name/controller.conf
%config(noreplace) %_sysconfdir/%name/driver.conf
%config %dir %_sysconfdir/%name/.controller
%config %_sysconfdir/%name/.controller/config.ini
%config %_sysconfdir/%name/controller-tomcat-server.xml
%config %_sysconfdir/%name/cosbench-users.xml
%config %_sysconfdir/%name/driver-tomcat-server.xml
%config %dir %_sysconfdir/%name/.driver
%config %_sysconfdir/%name/.driver/config.ini

%changelog

