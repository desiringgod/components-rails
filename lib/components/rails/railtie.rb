require 'rails/railtie'

module Components
  module Rails
    class Railtie < ::Rails::Railtie
      initializer 'components.prepare_helpers' do |app|
        Components::Rails::Component._helpers.module_eval do
          def default_url_options
            ::Rails.application.routes.default_url_options
          end

          include ::Rails.application.routes.url_helpers
        end
      end

      config.before_configuration do |app|
        app.config.autoload_paths += Dir[::Rails.root.join('app', 'components', '**', '**/')]
        app.config.eager_load_paths += Dir[::Rails.root.join('app', 'components', '**/')]
        app.config.paths['app/views'].unshift(File.join(::Rails.root, 'app', 'components'))
      end

      initializer 'components.rails_extensions' do |app|
        Components::Rails::ActionView.reload_component_helpers

        ActiveSupport.on_load(:action_controller) do
          class_eval do
            include Components::Rails::ActionView
          end
        end

        ActiveSupport.on_load(:action_view) do
          class_eval do
            include Components::Rails::ActionView
          end
        end
      end
    end
  end
end
