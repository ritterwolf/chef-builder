Chef OSS builder
================

This project aims to allow people to build Chef products from sources using omnibus.

Building with Omnibus effectively requires you to be root. It places files all over the filesystem, so you would need a
dedicated build PC to build anything, and there is no guarantee that it cleans up after itself properly. With this in
mind, this project uses Docker to provide the build machine, because we can throw it away once we're done, and be sure
that we're starting with a fresh instance.

The base image for each distribution is used, and as part of the build process any required bits are installed. Images
with the pre-requirements already installed aren't kept around, and aren't on the Docker Hub. This may come in the 
future.

Buildable packages
------------------

We can currently build
- chef
- chef-server
- inspec

Not attempted:
- chef-workstation

Can't build
- chef-automate - doesn't use omnibus.

Supported Distributions
-----------------------

Known working:
- Ubuntu 14.04

Partially working:
- Fedora (only builds chef)

Expected to work:
- Debian
- Ubuntu 16.04, 18.04+

I initially created this project at the start of 2020, and I can't promise that everything I say works still works.

HOWTO
-----

Run `./chef-build.sh <DISTRO> <DISTRO_VERS> <CHEF_PRODUCT> <PRODUCT_VERSION>`.

To build `chef` for Ubuntu 18.04 (Bionic Beaver) you would use:

```
./chef-build ubuntu bionic chef 15.5.15
```

In this case the package would end up in `pkg/ubuntu/bionic`. For Debian and Ubuntu you can use the codename or version;
`bionic` and `18.04` would build with the same image, but the built package ends up in a directory based on your input.

Developer Notes
---------------

- Documentation needs work
- Release tarballs have the pattern: https://github.com/chef/chef/archive/\<PREFIX\>\<VERSION\>.tar.gz \
  eg: 
    - https://github.com/chef/chef/archive/v15.5.15.tar.gz (prefix is v)
    - https://github.com/chef/chef-server/archive/13.1.1.tar.gz (no prefix)

TODO
----

- Add support for more distribution families.
- Add some sort of package caching.
- Run tests

WARNING
-------

Anything built by this project should only be used internally. You can use it as widely as you like, but I recommend
against distributing any packages you build outside your organisation. Chef still owns trademarks that are on the code,
and you don't get a licence to distribute things with those trademarks.

If you have trademark stripping patches, I'm willing to take them if they're under the Apache Licence, not because I 
have a preference (I do), but because it's just simpler.

License
-------

Copyright 2020 Lyle Dietz

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.