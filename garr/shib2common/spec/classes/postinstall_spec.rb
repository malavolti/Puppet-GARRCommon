#!/usr/bin/env rspec

require 'spec_helper'

describe 'shib2common::postinstall', :type => :class do
	let :title do
		'shib2common::postinstall.rspec'
	end

	let :pre_condition do
		 'include shib2common'
	end

	['shib2-tomcat-restart', 'shib2-apache-restart', 'shib2-shibd-restart'].each do |execname|
		it { should contain_exec("#{execname}") }
		#it { should notify("#{execname}") }
	end
end
