#WebLogic 11.1.1.7 infra (JRF) with SOA, BAM, OSB Cluster

with OSB & SOA with BPM, BAM, B2B

This is a back-port of Edwin Biemond's 12.2.1 SOA orawls on Vagrant implementation (https://github.com/biemond/biemond-orawls-vagrant-12.2.1-infra-soa) using the latest orawls and what you might call Edwin's "3rd generation" configuration approach. It is not yet fully patched to the latest 11g versions.

##Details
- CentOS 6.5 vagrant box
- Puppet 3.5.0
- Vagrant >= 1.41
- Oracle Virtualbox >= 4.3.6

Download & Add the all the Oracle binaries to /software

edit Vagrantfile and update the software share to your own local folder
- soadb.vm.synced_folder "/Users/edwin/software", "/software"
- soa2admin2.vm.synced_folder "/Users/edwin/software", "/software"

Vagrant boxes
- vagrant up soadb
- vagrant up soa2admin2
- vagrant up mft1admin

## Database
- soadb 10.10.10.5, 11.2.0.4 with Welcome01 as password

###operating users
- root vagrant
- vagrant vagrant
- oracle oracle

###software
- Oracle Database 12.1.0.4.0 SE Linux
-  p13390677_112040_Linux-x86-64_1of7.zip
-  p13390677_112040_Linux-x86-64_2of7.zip
- Oracle Database 11.2.0.4.2 PSU p18031668_112040_Linux-x86-64.zip
- OPatch 11.2.0.3.15 p6880880_112000_Linux-x86-64.zip

## Middleware

### default soa osb domain with 1 node
- soa2admin2 10.10.10.21, WebLogic 12.2.1 with Infra ( JRF, ADF, SOA, OSB ) requires RCU

http://10.10.10.21:7001/em with weblogic1 as password

###operating users
- root vagrant
- vagrant vagrant
- oracle oracle

###software
- JDK 1.7u55 jdk-7u55-linux-x64.tar.gz
- JDK 7 JCE policy UnlimitedJCEPolicyJDK7.zip
- WebLogic 11g wls1036_generic.jar
- WLS PSU 10.3.6.0.13 p21984589_1036_Generic.zip
- Oracle SOA Suite 11.1.1.7.0
-  ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip
-  ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip
- Oracle Service Bus 11.1.1.7.0
-  ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip
- SOA 11g BP 11.1.1.7.2 p17584181_111170_Generic.zip