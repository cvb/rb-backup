#!/usr/bin/env ruby1.9
# Copyright 2010 Peter Goncharov

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or	
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'yaml'
require 'optparse'

class Backuper
end

class ConfigParser
  @@config_name='~/.rb-backuper/config.yml'
  @@config
  def config_name=(name)
    @@config_name = name
  end
  def reader
    @@config = File.open(File.expand_path(@@config_name)) do |io| 
      YAML::load(io) 
    end
    puts @@config
  rescue => detail
    puts "Something bad happened when trying to read config:\n" + detail.message
  end
end

options={}

optparse = OptionParser.new do|opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner = "Usage: rb-backuper.rb -c config_file"
 
  options[:config_file] = nil
  opts.on( '-c', '--config FILE', 'Read config from FILE, default ~/.rb-backuper/config.yml' ) do|file|
    options[:config_file] = file
  end
 
   # This displays the help screen, all programs are
   # assumed to have this option.
   opts.on( '-h', '--help', 'Display this screen' ) do
     puts opts
     exit
  end
end.parse!

#optparse.parse
parser=ConfigParser.new
parser.config_name = options[:config_file] if options[:config_file]
parser.reader
