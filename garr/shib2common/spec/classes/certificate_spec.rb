#!/usr/bin/env rspec

require 'spec_helper'

describe 'shib2common::certificate', :type => :class do
    let :title do
        'shib2common::certificate.rspec'
    end

    let :pre_condition do
         'include shib2common'
    end

    let :default_params do
      {
        :hostfqdn         => 'idp.example.org',
        :keystorepassword => 'puppetpassword',
      }
    end

    it { should contain_file('/root/certificates/key-server.pem') }
    it { should contain_file('/root/certificates/cert-server.pem') }
    it { should contain_download_file('/root/certificates/Terena-chain.pem') }
end
