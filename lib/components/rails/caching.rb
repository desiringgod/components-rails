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
        @cached_render ||= read_fragment(cache_key)
      end

      def cache_render
        write_fragment(cache_key, response_body)
      end
    end
  end
end
