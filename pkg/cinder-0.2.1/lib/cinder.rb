require 'rubygems'
require 'uri'
require 'mechanize'
require 'csv'

Dir[File.join(File.dirname(__FILE__), 'cinder/**/*.rb')].sort.each { |lib| require lib }


module Cinder
  VERSION = '0.2.1'
  class Error < StandardError; end
end
