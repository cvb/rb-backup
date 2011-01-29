#!/usr/bin/env ruby1.9
require 'yaml'

class Backuper
end

class ConfigParser
  @@config_name='~/.rb-backuper/config.yml1'
  @@config
  def reader
    @@config = File.open(File.expand_path(@@config_name)) do |io| 
      YAML::load(io) 
    end
    puts @@config
  rescue => detail
    puts "Something bad happened when tryeing to read config:\n" + detail.message
  end
end

ConfigParser.new.reader
