# frozen_string_literal: true

require "yaml"

module Yomou
  class Config
    YOMOU_CONFIG = 'yomou.yaml'
    DOT_YOMOU = '.yomou'

    def initialize
      @keys = []
      if File.exist?(path)
        load
      else
        src = File.dirname(__FILE__) + "/../../examples/#{YOMOU_CONFIG}"
        FileUtils.cp(src, path)
        load
        if ENV['YOMOU_HOME']
          path = File.join(ENV['YOMOU_HOME'], 'db/yomou.db')
          instance_variable_set('@database', path)
        end
        save
      end
    end

    def directory
      directory = File.join(ENV['HOME'], DOT_YOMOU)
      directory = ENV['YOMOU_HOME'] if ENV['YOMOU_HOME']
      Dir.mkdir(directory) unless Dir.exist?(directory)
      directory
    end

    def path
      File.join(directory, YOMOU_CONFIG)
    end

    def narou_novel_directory(category)
      path = File.join(narou_category_directory(category),
                       @narou_novel)
      path
    end

    def narou_category_directory(category)
      path = File.join(directory,
                       'narou',
                       format("%02d", category.to_i))
      path
    end

    def load
      YAML.load_file(path).each do |key, value|
        @keys << key
        instance_variable_set("@#{key}", value)
      end
    end

    def save
      config = {}
      instance_variables.each do |var|
        key = var.to_s.sub(/^@/, '')
        config[key] = instance_variable_get(var.to_s) unless key == 'keys'
      end
      File.open(path, 'w+') do |file|
        file.puts(YAML.dump(config))
      end
    end

    def method_missing(method, *args)
      method_name = method.to_s
      if method_name.end_with?('=')
        property = method_name.sub(/=$/, '')
        @keys << property
        instance_variable_set("@#{property}", *args)
      else
        instance_variable_get("@#{method_name}")
      end
    end
  end
end
