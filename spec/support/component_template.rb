# frozen_string_literal: true

module ComponentTemplate
  def component_class
    @component_class ||= Class.new(Components::Rails::Component) { def cache_key; '123'; end }
  end

  def component_class_name
    @component_class_name ||= "my_#{Time.now.subsec.numerator}_component"
  end

  def set_component_template(template)
    component_class.send(:redefine_method, :show) do
      render inline: template
    end
  end

  def render_view_template(template)
    ActionView::Base.new.render(inline: template)
  end
end

RSpec.configure do |config|
  config.include ComponentTemplate, type: :component_template

  config.before(:example, type: :component_template) do
    ActionView::Base.include Components::Rails::ActionView
    Object.const_set(component_class_name.camelize, component_class)
    Components::Rails::ActionView.define_component_helper(component_class_name)
  end
end
