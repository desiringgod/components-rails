# frozen_string_literal: true

module Components
  module Rails
    module Attributes
      extend ActiveSupport::Concern

      included do
        class_attribute :defaults
        self.defaults = {}
      end

      def _render_template(options)
        super(options.merge(locals: defaults.merge(attributes)))
      end
    end
  end
end
