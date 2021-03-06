#!/usr/bin/env ruby1.9
# Copyright 2011 Peter Goncharov

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
  # Parse command line options
  def initialize
    parse_options
    load_config
    load_methods
  end
  
  def parse_options
    opts = Options.new
    @config_file = opts.config_file
  end

  # Load yml config
  def load_config
    parser = ConfigParser.new(@config_file)
    #parser.config_name=@config_file
    #puts parser.config
    @conf = parser.config
  end
  
  # Load backup methods
  def load_methods
    pn = Pathname.new(File.expand_path(@config_file))
    method_dir = pn.dirname + "methods/"
    method_files = Dir["#{method_dir}/*.rb"].each do |f|
      require f
    end
  end

  def have_undefined_methods?
    undefined_methods = []
    @conf.each_value do |name|
      begin
        puts name
        self.method(name['method'])
      rescue NameError => e
        undefined_methods.push e.name
        next
      end
    end
    undefined_methods
  end
  
  def run_backup
    und_meths = have_undefined_methods?
    bad_results = []            # Bad results of method execution will be here
    if not und_meths.empty?
      puts "Undefined methods: #{und_meths}"
      exit
    else 
      @conf.each_value do |name|
        r = self.method(name['method']).call name
        bad_results.push name['method'] + r if r
      end
    end
    puts bad_results
  end
end

class ConfigParser
  # Do all usefull work in initialize
  # parsing config file arguments
  attr_writer :config_name
  attr_reader :config
  
  def initialize(config_name)
    @config_name = config_name
    @config = File.open(File.expand_path(@config_name)) do |io| 
      YAML::load(io) 
    end
  rescue => detail
    puts "Something bad happened when trying to read config:\n" + detail.message
    exit
  end

  def print_config
    puts @config
  end
end

class Options
  # Parsing command line args
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
    #puts @opts
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
