Package{allow_virtual => false,}

node 'soadb.example.com' {
  include oradb_os
  include oradb_11g
}

# operating settings for Database & Middleware
class oradb_os {

  class { 'swap_file':
    swapfile     => '/var/swap.1',
    swapfilesize => '8192000000'
  }

  $host_instances = hiera('hosts', {})
  create_resources('host',$host_instances)

  service { iptables:
    enable    => false,
    ensure    => false,
    hasstatus => true,
  }

  $groups = ['oinstall','dba' ,'oper' ]

  group { $groups :
    ensure      => present,
  }

  user { 'oracle' :
    ensure      => present,
    uid         => 500,
    gid         => 'oinstall',
    groups      => $groups,
    shell       => '/bin/bash',
    password    => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
    home        => "/home/oracle",
    comment     => "This user oracle was created by Puppet",
    require     => Group[$groups],
    managehome  => true,
  }

  $install = ['binutils.x86_64',
              'compat-libstdc++-33.x86_64',
              'glibc.x86_64',
              'ksh.x86_64',
              'libaio.x86_64',
              'libgcc.x86_64',
              'libstdc++.x86_64',
              'make.x86_64',
              'compat-libcap1.x86_64',
              'gcc.x86_64',
              'gcc-c++.x86_64',
              'glibc-devel.x86_64',
              'libaio-devel.x86_64',
              'libstdc++-devel.x86_64',
              'sysstat.x86_64',
              'unixODBC-devel',
              'glibc.i686',
              'libXext.x86_64',
              'libXtst.x86_64']


  package { $install:
    ensure  => present,
  }

  class { 'limits':
     config => {
                '*'       => { 'nofile'  => { soft => '2048'   , hard => '8192',   },},
                'oracle'  => { 'nofile'  => { soft => '65536'  , hard => '65536',  },
                                'nproc'  => { soft => '2048'   , hard => '16384',  },
                                'stack'  => { soft => '10240'  ,},},
                },
     use_hiera => false,
  }

  sysctl { 'kernel.msgmnb':                 ensure => 'present', permanent => 'yes', value => '65536',}
  sysctl { 'kernel.msgmax':                 ensure => 'present', permanent => 'yes', value => '65536',}
  sysctl { 'kernel.shmmax':                 ensure => 'present', permanent => 'yes', value => '2588483584',}
  sysctl { 'kernel.shmall':                 ensure => 'present', permanent => 'yes', value => '2097152',}
  sysctl { 'fs.file-max':                   ensure => 'present', permanent => 'yes', value => '6815744',}
  sysctl { 'net.ipv4.tcp_keepalive_time':   ensure => 'present', permanent => 'yes', value => '1800',}
  sysctl { 'net.ipv4.tcp_keepalive_intvl':  ensure => 'present', permanent => 'yes', value => '30',}
  sysctl { 'net.ipv4.tcp_keepalive_probes': ensure => 'present', permanent => 'yes', value => '5',}
  sysctl { 'net.ipv4.tcp_fin_timeout':      ensure => 'present', permanent => 'yes', value => '30',}
  sysctl { 'kernel.shmmni':                 ensure => 'present', permanent => 'yes', value => '4096', }
  sysctl { 'fs.aio-max-nr':                 ensure => 'present', permanent => 'yes', value => '1048576',}
  sysctl { 'kernel.sem':                    ensure => 'present', permanent => 'yes', value => '250 32000 100 128',}
  sysctl { 'net.ipv4.ip_local_port_range':  ensure => 'present', permanent => 'yes', value => '9000 65500',}
  sysctl { 'net.core.rmem_default':         ensure => 'present', permanent => 'yes', value => '262144',}
  sysctl { 'net.core.rmem_max':             ensure => 'present', permanent => 'yes', value => '4194304', }
  sysctl { 'net.core.wmem_default':         ensure => 'present', permanent => 'yes', value => '262144',}
  sysctl { 'net.core.wmem_max':             ensure => 'present', permanent => 'yes', value => '1048576',}
}

class oradb_11g {
  require oradb_os

	  # full installer "11.2.0.4.0 PATCH SET FOR ORACLE DATABASE SERVER (Patchset)" release - not all zips needed
    oradb::installdb{ '11.2_linux-x64':
      version                => '11.2.0.4',
      file                   => 'p13390677_112040_Linux-x86-64',
      database_type           => 'SE',
      oracle_base             => hiera('oracle_base_dir'),
      oracle_home             => hiera('oracle_home_dir'),
      remote_file             => false,
      puppet_download_mnt_point => hiera('oracle_source'),
    }

	  # note: p6880880 is reused for different OPatch versions - you may need to update the version (which is checked)
    oradb::opatchupgrade{'112000_opatch_upgrade':
        oracle_home             => hiera('oracle_home_dir'),
        patch_file              => 'p6880880_112000_Linux-x86-64.zip',
        csi_number              => undef,
        support_id              => undef,
        opversion              => '11.2.0.3.15',
        puppet_download_mnt_point => hiera('oracle_source'),
        require                => Oradb::Installdb['11.2_linux-x64'],
    }

	  # "DATABASE PATCH SET UPDATE 11.2.0.4.2 (INCLUDES CPUAPR2014) (Patch)"
	  # note: superseded by "DATABASE PATCH SET UPDATE 11.2.0.4.160719"
    oradb::opatch{'18031668_db_patch':
      ensure                 => 'present',
      oracle_product_home      => hiera('oracle_home_dir'),
      patch_id                => '18031668',
      patch_file              => 'p18031668_112040_Linux-x86-64.zip',
      ocmrf                  => true,
      require                => Oradb::Opatchupgrade['112000_opatch_upgrade'],
      puppet_download_mnt_point => hiera('oracle_source'),
    }

    oradb::net{ 'config net8':
      oracle_home   => hiera('oracle_home_dir'),
      version      => '11.2',
      require      => Oradb::Opatch['18031668_db_patch'],
    }

    oradb::listener{'start listener':
      oracle_base   => hiera('oracle_base_dir'),
      oracle_home   => hiera('oracle_home_dir'),
      action       => 'start',
      require      => Oradb::Net['config net8'],
    }

    oradb::database{ 'oraDb':
      oracle_base              => hiera('oracle_base_dir'),
      oracle_home              => hiera('oracle_home_dir'),
      version                 => '11.2',
      action                  => 'create',
      db_name                  => hiera('oracle_database_name'),
      db_domain                => hiera('oracle_database_domain_name'),
      sys_password             => hiera('oracle_database_sys_password'),
      system_password          => hiera('oracle_database_system_password'),
      data_file_destination     => "/oracle/oradata",
      recovery_area_destination => "/oracle/flash_recovery_area",
      character_set            => "AL32UTF8",
      nationalcharacter_set    => "UTF8",
      init_params              => "open_cursors=1000,processes=600,job_queue_processes=4",
      sample_schema            => 'FALSE',
      memory_percentage        => "40",
      memory_total             => "800",
      database_type            => "MULTIPURPOSE",
      require                 => Oradb::Listener['start listener'],
    }

    oradb::dbactions{ 'start oraDb':
      oracle_home              => hiera('oracle_home_dir'),
      action                  => 'start',
      db_name                  => hiera('oracle_database_name'),
      require                 => Oradb::Database['oraDb'],
    }

    oradb::autostartdatabase{ 'autostart oracle':
      oracle_home              => hiera('oracle_home_dir'),
      db_name                  => hiera('oracle_database_name'),
      require                 => Oradb::Dbactions['start oraDb'],
    }

    oradb::tnsnames{'orcl':
      oracle_home         => hiera('oracle_home_dir'),
      server             => { myserver => { host => 'soadb.example.nl', port => '1521', protocol => 'TCP' }},
      connect_service_name => hiera('oracle_database_service_name'),
      require            => Oradb::Dbactions['start oraDb'],
    }

    oradb::tnsnames{'SOAREPOS':
      oracle_home         => hiera('oracle_home_dir'),
      server             => { myserver => { host => 'soadb.example.nl', port => '1521', protocol => 'TCP' }},
      connect_service_name => hiera('oracle_database_service_name'),
      connect_server      => 'DEDICATED',
      require            => Oradb::Dbactions['start oraDb'],
    }

    oradb::tnsnames{'testlistener':
      entry_type         => 'listener',
      oracle_home         => hiera('oracle_home_dir'),
      server             => { myserver => { host => 'soadb.example.nl', port => '1521', protocol => 'TCP' }},
      require            => Oradb::Dbactions['start oraDb'],
    }


    oradb::rcu{  'DEV_RCU':
      rcu_file                => 'ofm_rcu_linux_11.1.1.7.0_64_disk1_1of1.zip',
      product                 => hiera('repository_type'),
      version                 => '11.1.1.7',
      action                  => 'create',
      oracle_home             => hiera('oracle_home_dir'),
      db_server               => hiera('oracle_database_host'),
      db_service              => hiera('oracle_database_service_name'),
      sys_password            => hiera('oracle_database_sys_password'),
      schema_prefix           => hiera('repository_prefix'),
      repos_password          => hiera('repository_password'),
      temp_tablespace         => 'TEMP',
      puppet_download_mnt_point => hiera('oracle_source'),
      remote_file             => true,
      logoutput               => true,
      require                 => Oradb::Dbactions['start oraDb'],
    }

    # oradb::rcu{  'DEV2_RCU':
    #   rcuFile                => 'ofm_rcu_linux_11.1.1.7.0_64_disk1_1of1.zip',
    #   product                => hiera('repository_type2'),
    #   version                => '11.1.1.7',
    #   user                   => hiera('oracle_os_user'),
    #   group                  => hiera('oracle_os_group'),
    #   download_dir            => hiera('oracle_download_dir'),
    #   action                 => 'create',
    #   oracle_home             => hiera('oracle_home_dir'),
    #   dbServer               => hiera('oracle_database_host'),
    #   dbService              => hiera('oracle_database_service_name'),
    #   sysPassword            => hiera('oracle_database_sys_password'),
    #   schemaPrefix           => hiera('repository_prefix2'),
    #   reposPassword          => hiera('repository_password2'),
    #   tempTablespace         => 'TEMP',
    #   puppet_download_mnt_point => hiera('oracle_source'),
    #   remoteFile             => true,
    #   logoutput              => true,
    #   require                => Oradb::Rcu['DEV_RCU'],
    # }

}

# this oradb_configuration class isn't used by the 11g scripts by default
class oradb_configuration {
  require oradb_11g

  ora_init_param{'SPFILE/processes@soarepos':
    ensure => 'present',
    value  => '1000',
  }

  ora_init_param{'SPFILE/job_queue_processes@soarepos':
    ensure  => present,
    value   => '4',
  }

  db_control{'soarepos restart':
    ensure                  => 'running', #running|start|abort|stop
    instance_name           => hiera('oracle_database_name'),
    oracle_product_home_dir => hiera('oracle_home_dir'),
    os_user                 => hiera('oracle_os_user'),
    refreshonly             => true,
    subscribe               => [Ora_init_param['SPFILE/processes@soarepos'],
                                Ora_init_param['SPFILE/job_queue_processes@soarepos'],],
  }

  ora_tablespace {'JMS_TS@soarepos':
    ensure                    => present,
    datafile                  => 'jms_ts.dbf',
    size                      => 100M,
    logging                   => yes,
    autoextend                => on,
    next                      => 100M,
    max_size                  => 1G,
    extent_management         => local,
    segment_space_management  => auto,
  }

  ora_role {'APPS@soarepos':
    ensure    => present,
  }

  ora_user{'JMS@soarepos':
    ensure                    => present,
    temporary_tablespace      => temp,
    default_tablespace        => 'JMS_TS',
    password                  => 'jms',
    require                   => [Ora_tablespace['JMS_TS@soarepos'],
                                  Ora_role['APPS@soarepos']],
    grants                    => ['SELECT ANY TABLE', 'CONNECT', 'CREATE TABLE', 'CREATE TRIGGER','APPS'],
    quotas                    => {
                                    "JMS_TS"  => 'unlimited'
                                  },
  }

}

