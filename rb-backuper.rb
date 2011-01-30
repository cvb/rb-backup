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
require 'pathname'

class Backuper
  def parse_options
    opts = Options.new
    @config_file = opts.config_file
  end
  def load_config
    parser = ConfigParser.new(@config_file)
    #parser.config_name=@config_file
    @conf = parser.config
  end
  def load_methods
    pn = Pathname.new(File.expand_path(@config_file))
    method_dir = pn.dirname + "methods/"
    method_files = Dir["#{method_dir}/*.rb"].each do |f|
      require f
    end
  end
  def run_backup
    parse_options
    load_config
    load_methods
  end

end

class ConfigParser
  def initialize(config_name)
    @config_name = config_name
    @config = File.open(File.expand_path(@config_name)) do |io| 
      YAML::load(io) 
    end
  end
  def config_name=(name)
    @config_name = name
  end
  def print_config
    puts @config
  end
  def config
    @config
  end
  def read
    @config = File.open(File.expand_path(@config_name)) do |io| 
      YAML::load(io) 
    end
  rescue => detail
    puts "Something bad happened when trying to read config:\n" + detail.message
    exit
  end
end

class Options
  def initialize
    @opts = {}
    optparse = OptionParser.new do|opts|
      # Set a banner, displayed at the top
      # of the help screen.
      opts.banner = "Usage: rb-backuper.rb -c config_file"
      
      @opts[:config_file] = '~/.rb-backuper/config.yml'
      opts.on( '-c', '--config FILE', 'Read config from FILE, default ~/.rb-backuper/config.yml' ) do|file|
        puts "setting file to #{file}"
        @opts[:config_file] = file
      end
      
      # This displays the help screen, all programs are
      # assumed to have this option.
      opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        exit
      end
    end.parse!
  end
  
  def config_file
    puts @opts
    @opts[:config_file]
  end
end

#optparse.parse
#parser=ConfigParser.new
#parser.config_name = options[:config_file] if options[:config_file]
#parser.reader
#parser.print_config
b=Backuper.new
b.method("run_backup").call
