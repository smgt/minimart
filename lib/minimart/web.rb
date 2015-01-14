require 'minimart/web/universe_generator'
require 'minimart/web/html_generator'

require 'minimart/cookbook'

module Minimart
  class Web

    attr_reader :inventory_directory
    attr_reader :web_directory
    attr_reader :endpoint
    attr_reader :universe

    def initialize(opts = {})
      @inventory_directory = File.expand_path(opts[:inventory_directory])
      @web_directory       = File.expand_path(opts[:web_directory])
      @endpoint            = opts[:endpoint]
      @universe            = {}
    end

    def execute!
      make_web_directory
      generate_universe
      generate_html
    end

    private

    def make_web_directory
      FileUtils.mkdir_p web_directory
    end

    def generate_universe
      generator = Web::UniverseGenerator.new(
        web_directory: web_directory,
        endpoint:      endpoint,
        cookbooks:     cookbooks)

      generator.generate
    end

    def generate_html
      generator = Web::HtmlGenerator.new(
        web_directory: web_directory,
        cookbooks:     cookbooks)

      generator.generate
    end

    def cookbooks
      @cookbooks ||= inventory_cookbook_paths.map { |path| Minimart::Cookbook.new(path) }
    end

    def inventory_cookbook_paths
      Utils::FileHelper.find_cookbooks_in_directory(inventory_directory)
    end

  end
end
