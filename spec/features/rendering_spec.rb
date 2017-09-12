# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Component rendering' do
  let(:component_class) { Class.new(Components::Rails::Component) { def cache_key; '123'; end } }
  let(:component_class_name) { "my_#{Time.now.subsec.numerator}_component" }
  let(:action_view) { ActionView::Base.new }

  before do
    ActionView::Base.include Components::Rails::ActionView
    Object.const_set(component_class_name.camelize, component_class)
    Components::Rails::ActionView.define_component_helper(component_class_name)
  end

  describe 'with attribute' do
    before do
      component_class.send(:redefine_method, :show) do
        render inline: <<~eos
          some content

          <%= an_attribute %>

          more content
        eos
      end
    end

    it 'works' do
      expect(action_view.render(inline: "template <%= #{component_class_name}(an_attribute: 'val') %>")).to eq(<<~eos)
        template some content

        val

        more content
      eos
    end

    describe 'setting defaults' do
      before { component_class.defaults = {an_attribute: 'default value'} }

      context 'with attribute' do
        it 'uses the value' do
          expect(
            action_view.render(inline: "template <%= #{component_class_name}(an_attribute: 'given val') %>")
          ).to eq(<<~eos)
            template some content

            given val

            more content
          eos
        end
      end

      context 'without attribute' do
        it 'uses the default value' do
          expect(action_view.render(inline: "template <%= #{component_class_name} %>")).to eq(<<~eos)
            template some content

            default value

            more content
          eos
        end
      end
    end
  end

  describe 'with block' do
    before do
      component_class.send(:redefine_method, :show) do
        render inline: <<~eos
          some content

          <%= block_content %>

          more content
        eos
      end

      component_class.send(:redefine_method, :cache_key) do
        [attributes[:an_attribute], block_content]
      end
    end

    it 'works' do
      expect(
        action_view.render(
          inline: "template <%= #{component_class_name}(an_attribute: 'value') do %>content from block<% end %>"
        )
      ).to eq(<<~eos)
        template some content

        content from block

        more content
      eos
    end

    describe 'block_content in #cache_key' do
      subject do
        component_class.new(nil, ActionView::Base.new, :show, an_attribute: :value, block: proc { 'the block' })
      end

      it 'works' do
        expect(subject.cache_key).to eq([:value, 'the block'])
      end
    end
  end
end
