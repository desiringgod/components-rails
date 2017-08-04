module Components
  module Rails
    module ActionView
      def define_component_helper(name)
        define_method(name) do |options = {}, &block|
          render(component(name, options, &block))
        end
      end
      module_function :define_component_helper

      def component_directories
        dir = ::Rails.root.join('app', 'components')
        Dir.entries(dir).select { |f| File.directory? File.join(dir, f) }
      end
      module_function :component_directories

      def filtered_component_directories
        ignored_dirs = ['.', '..', 'concerns']
        component_directories.reject { |f| ignored_dirs.include? f }
      end
      module_function :filtered_component_directories

      def reload_component_helpers
        filtered_component_directories.each { |name| define_component_helper(name) }
      end
      module_function :reload_component_helpers

      def component(component, options = {}, &block)
        action = options.delete(:action) || :show
        {html: Component.render_action(action, self, options.merge(component: component), &block)}
      end
    end
  end
end