require 'sinatra'
require 'sequel'
require 'slim'
require 'yaml'
require 'digest'
require 'digest/md5'
require 'bundler/setup'

Bundler.require

ENV['RACK_ENV'] = 'development'

require File.join(File.dirname(__FILE__), 'app.rb')

Todo.start!