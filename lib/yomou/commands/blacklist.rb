# frozen_string_literal: true

require 'thor'

module Yomou
  module Commands
    class Blacklist < Thor

      namespace :blacklist

      desc 'init', 'Command description...'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def init(*)
        if options[:help]
          invoke :help, ['init']
        else
          require_relative 'blacklist/init'
          Yomou::Commands::Blacklist::Init.new(options).execute
        end
      end
    end
  end
end
