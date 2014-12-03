module Minimart
  class Mirror
    class InventoryBuilder

      attr_reader :inventory_configuration,
                  :graph,
                  :local_store

      def initialize(inventory_directory, inventory_configuration)
        @inventory_configuration = inventory_configuration
        @graph = DependencyGraph.new
        @local_store = LocalStore.new(inventory_directory)
      end

      def build!
        install_cookbooks_with_location_dependency
        add_remote_cookbooks_to_graph
        add_inventory_requirements_to_graph
        fetch_inventory
      end

      private

      def install_cookbooks_with_location_dependency
        inventory_requirements.each do |cookbook_requirement|
          next unless cookbook_requirement.location_specification?
          # any dependencies found here take precendence over those from sources listed in the inventory
          add_cookbook_to_graph(cookbook_requirement.cookbook_info)
          add_cookbook_to_local_store(cookbook_requirement.cookbook_path)
        end
      end

      def add_remote_cookbooks_to_graph
        sources.each_cookbook do |cookbook|
          add_cookbook_to_graph(cookbook)
        end
      end

      def add_inventory_requirements_to_graph
        inventory_requirements.each do |cookbook_requirement|
          add_inventory_requirement_to_graph(cookbook_requirement.requirements)
        end
      end

      def fetch_inventory
        resolved_requirements.each do |resolved_requirement|
          install_cookbook(*resolved_requirement)
        end
      end

      def resolved_requirements
        graph.resolved_requirements
      end

      def install_cookbook(name, version)
        if cookbook_already_installed?(name, version)
          Configuration.output.puts("cookbook already installed: #{name}-#{version}.")
          return
        end

        add_cookbook_to_local_store(download_cookbook(name, version))
      end

      def cookbook_already_installed?(name, version)
        local_store.installed?(name, version)
      end

      def add_cookbook_to_local_store(cookbook_path)
        local_store.add_cookbook_from_path(cookbook_path)
      end

      def download_cookbook(name, version)
        Download::Supermarket.download(find_cookbook(name, version))
      end

      def find_cookbook(name, version)
        sources.find_cookbook(name, version)
      end

      def add_cookbook_to_graph(cookbook)
        graph.add_remote_cookbook(cookbook)
      end

      def add_inventory_requirement_to_graph(requirements)
        graph.add_inventory_requirement(requirements)
      end

      def inventory_requirements
        inventory_configuration.requirements
      end

      def sources
        inventory_configuration.sources
      end
    end
  end
end
