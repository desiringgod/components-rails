# frozen_string_literal: true

module Components
  module Rails
    module Attributes
      extend ActiveSupport::Concern

      protected

      def prepare_attributes(attributes)
        registered_attributes_with_default_values.merge(attributes)
      end

      def registered_attributes_with_default_values
        self.class.registered_attributes.map { |k, v| [k, v[:default]] }.to_h
      end

      module ClassMethods
        def attribute(name, options = {})
          registered_attributes[name] = options
        end

        def registered_attributes
          @registered_attributes ||= {}
        end
      end
    end
  end
end
