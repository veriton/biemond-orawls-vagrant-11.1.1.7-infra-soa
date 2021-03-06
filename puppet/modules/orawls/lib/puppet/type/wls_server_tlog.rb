require File.dirname(__FILE__) + '/../../orawls_core'


module Puppet
  Type.newtype(:wls_server_tlog) do
    include EasyType
    include Utils::WlsAccess
    extend Utils::TitleParser

    desc 'This resource allows you to manage server tlog in an WebLogic domain.'

    ensurable

    set_command(:wlst)

    to_get_raw_resources do
      Puppet.debug "index #{name} "
      environment = { 'action' => 'index', 'type' => 'wls_server' }
      wlst template('puppet:///modules/orawls/providers/wls_server_tlog/index.py.erb', binding), environment
    end

    on_create do | command_builder |
      wlst_action = 'create'
      Puppet.info "create #{name} "
      template('puppet:///modules/orawls/providers/wls_server_tlog/create_modify.py.erb', binding)
    end

    on_modify do | command_builder |
      wlst_action = 'modify'
      Puppet.info "modify #{name} "
      template('puppet:///modules/orawls/providers/wls_server_tlog/create_modify.py.erb', binding)
    end

    on_destroy do | command_builder |
      Puppet.info "destroy #{name} "
      template('puppet:///modules/orawls/providers/wls_server_tlog/destroy.py.erb', binding)
    end

    parameter :domain
    parameter :name
    parameter :server_name

    property :tlog_enabled
    property :tlog_datasource
    property :tlog_datasource_prefix

    add_title_attributes(:server_name) do
      /^((.*\/)?(.*)?)$/
    end

  end
end
