#!/usr/bin/env rspec

require 'spec_helper'

describe 'shib2common::instance', :type => :define do
	let :title do
		'shib2common.rspec'
	end

	it { should compile.with_all_deps }

	it { should contain_class("shib2common::certificate") }
	it { should contain_class("shib2common::prerequisites") }
	it { should contain_class("shib2common::postinstall") }
end
