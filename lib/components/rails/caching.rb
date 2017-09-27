# frozen_string_literal: true

module Components
  module Rails
    module Caching
      def render(*args, &block)
        return super if self.class == Component
        return super unless perform_caching

        if cached_render.present?
          self.response_body = cached_render
        else
          super
          cache_render
        end
      end

      def cached_render
        @cached_render ||= read_fragment(cache_fragment_name)
      end

      def cache_render
        write_fragment(cache_fragment_name, response_body)
      end

      def cache_fragment_name
        if digest = ::ActionView::Digestor.digest(name: virtual_path, finder: lookup_context)
          ["#{virtual_path}:#{digest}", cache_key]
        else
          [virtual_path, name]
        end
      end

      # See AbstractConntroller::Caching::Fragments
      # Will eventually be deprecated and converted to combined_fragment_cache_key
      # Then it should become: super.tap(&:shift).unshift(:components)
      # In the meantime, it'll replace a leading "views/" with "components/"
      def fragment_cache_key(key)
        super.sub(%r{^views\/}, 'components/')
      end

      def virtual_path
        "#{component_path}/#{action_name}"
      end

      def instrument_payload(key)
        {
          component: component_name,
          action: action_name,
          key: key
        }
      end

      def instrument_name
        'components'
      end
    end
  end
end
