#!/usr/bin/env rspec

require 'spec_helper'

describe 'shib2common::prerequisites', :type => :class do
    let :title do
        'shib2common::prerequisites.rspec'
    end

    let :pre_condition do
         'include shib2common'
    end

    let :default_params do
      {
        :install_apache          => false,
        :install_tomcat          => false,
        :configure_admin         => false,
        :tomcat_admin_password   => '',
        :tomcat_manager_password => '',
        :hostfqdn                => 'idp.example.org',
        :mailto                  => 'support@garr.it',
      }
    end

    ['openssl', 'ntp', 'expat', 'ca-certificates', 'unzip', 'wget', 'expect'].each do |packagename|
        it { should contain_package("#{packagename}") }
    end

    context 'with install_apache => true' do
        let :params do
            default_params.merge({ :install_apache => true })
        end

        let :facts do
          {
            :osfamily               => 'Debian',
            :operatingsystemrelease => '12.04',
            :concat_basedir         => '/var/lib/puppet/concat',
          }
        end

        ['apache', 'apache::mod::ssl', 'apache::mod::proxy', 'apache::mod::php'].each do |classname|
            it { should contain_class("#{classname}") }
        end

        it { should contain_file('/etc/apache2/sites-enabled/default').with_target('/etc/apache2/sites-available/default') }
        it { should contain_file('/etc/apache2/sites-enabled/default-ssl').with_target('/etc/apache2/sites-available/default-ssl') }

        context 'with install_tomcat => true' do
            let :params do
                default_params.merge({ :install_apache => true, :install_tomcat => true })
            end

            it { should contain_apache__mod('proxy_ajp') }

            $defaultssl_attributes = {
                :servername => 'idp.example.org:443',
                :ssl => true,
                :ssl_cert => '/root/certificates/cert-server.pem',
                :ssl_key => '/root/certificates/key-server.pem',
                :ssl_chain => '/root/certificates/Terena-chain.pem',
            }
            it { should contain_apache__vhost('default-ssl-443').with($defaultssl_attributes) }

            context 'with configure_admin => true' do
                let :params do
                    default_params.merge({
                        :install_apache          => true,
                        :install_tomcat          => true,
                        :configure_admin         => true,
                        :tomcat_admin_password   => 'password1',
                        :tomcat_manager_password => 'password2',
                    })
                end

		$tomcatadmin_attributes = {
                    :tomcat_admin_password => 'password1',
                    :tomcat_manager_password => 'password2',
                }
                it { should contain_class('tomcat::admin').with($tomcatadmin_attributes) }
            end
        end
    end
end
