#!/usr/bin/env rspec

require 'spec_helper'
require 'facter/pupmaster'

describe 'Facter::Util::Fact' do
  before { Facter.clear }
  after { Facter.clear }

  it 'localhost.localdomain' do
    File.stubs(:exists?).returns(true)
    File.stubs(:open).returns('server=localhost.localdomain')
    Facter.fact(:pupmaster).value.should == 'localhost.localdomain'
  end
end
