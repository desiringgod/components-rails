require 'action_view/renderer/partial_renderer' # needed for PartialIteration

module Components
  module Rails
    class Component
      include ::ActiveSupport::Configurable
      include ::AbstractController::Rendering
      include ::ActionView::Rendering
      include ::AbstractController::Helpers
      include ::AbstractController::Caching
      include Caching

      attr_accessor :object, :view, :options, :response_body
      attr_reader :block_content
      helper_method :object, :block_content, :options

      delegate :cache, :'output_buffer=', :output_buffer, to: :view
      delegate :cache_store, to: :class

      def initialize(object, view, action, options = {})
        @object = object
        @view = view
        @options = options
        @action = action

        @block_content = options[:block].call if options[:block]
      end

      def action_name
        @action
      end

      def cache_key
        return false if ::Rails.env.development?
        raise NotImplementedError, 'You must implement #cache_key'
      end

      def view_assigns
        {
          action_name: action_name,
          component_name: component_name
        }
      end

      def _process_options(options)
        super.tap do |opts|
          if self.options[:collection_iteration]
            opts[:locals] = {collection_iteration: self.options[:collection_iteration]}
          end
        end
      end

      def component_name
        options[:component] || self.class.component_name
      end

      def perform_caching
        cache_key && self.class.perform_caching
      end

      def default_template
        self.class == Components::Rails::Component ? "#{options[:component]}/#{action_name}" : action_name.to_s
      end

      def default_render
        render(default_template)
      end

      private

      def instrument_payload(key)
        {
          component: component_name,
          action: action_name,
          key: key
        }
      end

      def instrument_name
        'component'
      end

      class << self
        delegate :perform_caching, :cache_store, to: :application_controller

        def _prefixes
          @_prefixes ||= begin
            return local_prefixes if superclass == Object

            local_prefixes + superclass._prefixes
          end
        end

        def render_action(action, view, options = {}, &block)
          options[:block] = block if block
          collection = options.delete(:collection)
          if collection
            iterator = ::ActionView::PartialIteration.new(collection.size)
            return render_collection(action, view, collection, options.merge(collection_iteration: iterator))
          end

          object = options.delete(:object)
          render_object(action, view, object, options)
        end

        def supports_path?
          false
        end

        def _view_paths
          ApplicationController._view_paths
        end

        def component_name
          name.demodulize.sub(/Component/, '').underscore
        end

        protected

        def render_collection(action, view, collection, options)
          collection.collect do |object|
            render_object(action, view, object, options).tap { options[:collection_iteration].iterate! }
          end.join.html_safe
        end

        def render_object(action, view, object, options)
          component = new_component(action, view, object, options)

          component.send(action) if component.respond_to?(action)
          component.default_render if component.response_body.nil?

          component.response_body
        end

        def new_component(action, view, object, options)
          klass = component_class(options[:component])
          klass.new(object, view, action, options)
        end

        def component_class(klass)
          klass = "#{klass}_component" unless klass =~ /component/
          klass.camelize.constantize
        rescue NameError => ex
          self
        end

        # Override this method in your component if you want to change paths prefixes for finding views.
        # Prefixes defined here will still be added to parents' <tt>._prefixes</tt>.
        def local_prefixes
          [component_path]
        end

        def component_path
          component_name.presence || 'application'
        end

        def application_controller
          ApplicationController
        end
      end
    end
  end
end
