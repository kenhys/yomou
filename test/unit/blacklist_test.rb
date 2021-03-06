# frozen_string_literal: true

require 'tmpdir'
require_relative '../../lib/yomou/blacklist'

class BlacklistTest < Test::Unit::TestCase
  setup do
    @empty_ncodes = {
      'ncodes': [
        'n12345'
      ]
    }
    @deleted_database = {
      1 => {
        'id' => 1,
        'toc_url' => 'http://ncode.syosetu.com/n98765/',
        'tags' => [
          '404'
        ]
      }
    }
  end

  sub_test_case "directory" do
    def test_directory
      sandbox do
        path = File.join(ENV['YOMOU_HOME'], 'blacklist.yaml')
        blacklist = Yomou::Blacklist.new
        blacklist.init
        assert_equal(true, File.exist?(path))
      end
    end

    def test_non_initialized_directory
      sandbox do
        path = File.join(ENV['YOMOU_HOME'], 'blacklist.yaml')
        output = StringIO.new
        blacklist = Yomou::Blacklist.new(output: output)
        assert_equal(false, blacklist.import)
      end
    end
  end

  sub_test_case "merge ncodes" do
    def test_merge_ncode
      sandbox do
        save_to_yaml(blacklist_path, @empty_ncodes)
        output = StringIO.new
        blacklist = Yomou::Blacklist.new(output: output)
        blacklist.init
        save_to_yaml(database_path('narou/00/.narou'), @deleted_database)
        blacklist.import
        expected = {
          'ncodes': [
            'n12345', 'n98765'
          ]
        }
        assert_equal(expected, YAML.load_file(blacklist_path))
      end
    end

    def test_specified_directory
      sandbox do
        save_to_yaml(blacklist_path, @empty_ncodes)
        output = StringIO.new
        blacklist = Yomou::Blacklist.new(output: output)
        blacklist.init
        save_to_yaml(database_path('narou/00/.narou'), database(0, 'n00000'))
        save_to_yaml(database_path('narou/01/.narou'), database(1, 'n11111'))
        blacklist.import(min: 0, max: 1)
        expected = {
          'ncodes': [
            'n00000', 'n11111', 'n12345'
          ]
        }
        assert_equal(expected, YAML.load_file(blacklist_path))
      end
    end
  end

  private

  def blacklist_path
    File.join(ENV['YOMOU_HOME'], 'blacklist.yaml')
  end

  def database_path(relative_path)
    path = File.join(ENV['YOMOU_HOME'], relative_path, 'database.yaml')
    FileUtils.mkdir_p(File.dirname(path))
    path
  end

  def save_to_yaml(path, data)
    FileUtils.mkdir_p(ENV['YOMOU_HOME'])
    File.open(path, 'w+') do |file|
      file.puts(YAML.dump(data))
    end
  end

  def database(id, ncode, deleted=true)
    data = {
      id => {
        'id' => id,
        'toc_url' => "http://ncode.syosetu.com/#{ncode}/"
      }
    }
    data[id]['tags'] = ['404'] if deleted
    data
  end
end
