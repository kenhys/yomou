# frozen_string_literal: true

require 'yomou/helper'
require 'rroonga'
require 'find'

module Yomou
  class Blacklist
    include Yomou::Helper
    YOMOU_BLACKLIST = 'blacklist.yaml'
    def initialize(options={})
      @conf = Yomou::Config.new
      @options = options
      @output = options[:output] || $stdout
    end

    def init
      path = File.join(@conf.directory, 'blacklist.yaml')
      unless File.exist?(path)
        source = File.dirname(__FILE__) + "/../../data/#{YOMOU_BLACKLIST}"
        FileUtils.cp(source, path)
      end
    end

    def import(options={})
      min = options[:min] || 0
      max = options[:max] || 99
      unless File.exist?(blacklist_path)
        @output.puts("#{YOMOU_BLACKLIST} not found, execute yomou blacklist init.")
        return false
      end

      @output.puts("load #{blacklist_path}...")
      yaml = YAML.load_file(blacklist_path)
      ncodes = yaml[:ncodes]
      directories = sub_directories(min, max)
      if directories.empty?
        directories = 99.times.collect do |i|
          format("%02d", i)
        end
      end
      base_dir = File.join(@conf.directory, 'narou')
      directories.each do |seq|
        database_path = File.join(base_dir, seq, '.narou', 'database.yaml')
        next unless File.exist?(database_path)
        @output.puts("load #{database_path}...")
        YAML.load_file(database_path).each do |_, entry|
          if entry.key?('tags') and entry['tags'].include?('404')
            ncode = extract_ncode(entry['toc_url'])
            ncodes << ncode unless ncode.empty?
          end
        end
      end
      @output.puts("save blacklist to #{blacklist_path}...")
      File.open(blacklist_path, 'w+') do |file|
        file.puts(YAML.dump(ncodes: ncodes.sort.uniq))
      end
    end

    private

    def extract_ncode(toc_url)
      ncode = ""
      if toc_url =~ /.+\/(n.+)\/$/
        ncode = $1
      end
      ncode
    end

    def blacklist_path
      base_dir = File.join(@conf.directory, 'narou')
      File.join(@conf.directory, YOMOU_BLACKLIST)
    end

    def sub_directories(min, max)
      n = 0
      directories = []
      loop do
        break if n > max
        if n >= min
          directories << format("%<number>02d", number: n)
        end
        n += 1
      end
      directories
    end
  end
end
