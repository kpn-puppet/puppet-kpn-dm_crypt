2020-02-11 Release 0.4.0
- Added RH8 support
- PE6 adjustments

2018-03-20 Release 0.3.0
- To locate the puppet agent cert files we now use the agent->certname from the puppet.config
- Lot's of rubocop improvement in code styling

2018-03-01 Release 0.2.1
- Created a custom fact encrypted_secret that can be used as password

2017-10-16 Release 0.2.0
- package_name & package_ensure, so package can be removed
- Moved data to hiera-structure
- Removed default values from config.pp and install.pp (no need)
- Fixed syntax issues
- Fixed beaker, remove crypt package from image when present before apply
- Fixed rspec, the package is different on RH6 & RH7, check the right package

2017-10-13 Release 0.1.0

- First Release
