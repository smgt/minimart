require 'ridley'
require 'minimart/web/markdown_parser'

module Minimart
  class Cookbook

    def initialize(path_to_cookbook)
      @raw_cookbook = Ridley::Chef::Cookbook.from_path(path_to_cookbook)
    end

    def name
      raw_cookbook.cookbook_name
    end

    def version
      raw_cookbook.version
    end

    # Return a the cookbook name, and version number separated by a dash
    def to_s
      raw_cookbook.name
    end

    def description
      metadata.description
    end

    def maintainer
      metadata.maintainer
    end

    def path
      raw_cookbook.path
    end

    def web_friendly_version
      version.gsub('.', '_')
    end

    def dependencies
      metadata.dependencies
    end

    def readme_file
      @readme_file ||= find_file('readme')
    end

    def changelog_file
      @changelog_file ||= find_file('changelog')
    end

    def readme_content
      @readme_content ||= Web::MarkdownParser.parse(readme_file) if readme_file
    end

    def changelog_content
      @changelog_content ||= Web::MarkdownParser.parse(changelog_file) if changelog_file
    end

    private

    attr_reader :raw_cookbook

    def metadata
      raw_cookbook.metadata
    end

    def find_file(name)
      Dir.glob(File.join(path, '*')).find do |file|
        File.basename(file, File.extname(file)) =~ /\A#{name}\z/i
      end
    end

    def path_to_file(file)
      File.join(self.path, file)
    end
  end
end
