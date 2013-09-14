require 'vagrant'
require 'pe_build/version'

if Vagrant::VERSION < "1.1.0"
  raise "vagrant-pe_build version #{PEBuild::VERSION} requires Vagrant 1.1 or later"
end

module PEBuild
  class Plugin < Vagrant.plugin('2')

    name 'pe_build'

    description <<-DESC
    This plugin adds commands and provisioners to automatically install Puppet
    Enterprise on Vagrant guests.
    DESC

    # User facing plugin configuration

    config(:pe_bootstrap, :provisioner) do
      require_relative 'config'
      PEBuild::Config::PEBootstrap
    end

    config(:pe_build) do
      require_relative 'config'
      PEBuild::Config::Global
    end

    provisioner(:pe_bootstrap) do
      require_relative 'provisioner/pe_bootstrap'
      PEBuild::Provisioner::PEBootstrap
    end

    command(:'pe-build') do
      require_relative 'command'
      PEBuild::Command::Base
    end

    # Guest capabilities for installing PE

    ## Detect installer

    guest_capability('debian', 'detect_installer') do
      require_relative 'cap'
      PEBuild::Cap::DetectInstaller::Debian
    end

    guest_capability('redhat', 'detect_installer') do
      require_relative 'cap'
      PEBuild::Cap::DetectInstaller::Redhat
    end

    guest_capability('ubuntu', 'detect_installer') do
      require_relative 'cap'
      PEBuild::Cap::DetectInstaller::Ubuntu
    end

    guest_capability('suse', 'detect_installer') do
      require_relative 'cap'
      PEBuild::Cap::DetectInstaller::SLES
    end

    guest_capability('solaris', 'detect_installer') do
      require_relative 'cap'
      PEBuild::Cap::DetectInstaller::Solaris
    end

    ## Run install

    guest_capability('linux', 'run_install') do
      require_relative 'cap'
      PEBuild::Cap::RunInstall::POSIX
    end

    guest_capability('solaris', 'run_install') do
      require_relative 'cap'
      PEBuild::Cap::RunInstall::POSIX
    end

    # internal action hooks

    action_hook('PE Build: initialize build dir') do |hook|
      require 'pe_build/action'
      hook.prepend PEBuild::Action::PEBuildDir
    end

    def self.config_builder_hook
      require_relative 'config_builder'
    end
  end
end
