#!/usr/bin/env ruby


require 'rubygems'
require 'bundler/setup'
require File.expand_path(File.join(File.dirname(__FILE__), 'nanomart'))


Log.logfile = "/tmp/purchases.log"
nanomart = Nanomart.new

nanomart.sell_me(:beer)
