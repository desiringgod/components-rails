# frozen_string_literal: true

module Components
  module Rails
    module Attributes
      def _render_template(options)
        super(options.merge(locals: attributes))
      end
    end
  end
end
