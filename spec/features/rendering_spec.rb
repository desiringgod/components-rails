# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Component rendering', type: :component_template do
  describe 'with attribute' do
    before do
      set_component_template(<<~eos)
        some content

        <%= an_attribute %>

        more content
      eos
    end

    it 'works' do
      view_template = "template <%= #{component_class_name}(an_attribute: 'val') %>"

      expect(render_view_template(view_template)).to eq(<<~eos)
        template some content

        val

        more content
      eos
    end

    describe 'setting defaults' do
      before { component_class.defaults = {an_attribute: 'default value'} }

      context 'with attribute' do
        it 'uses the value' do
          view_template = "template <%= #{component_class_name}(an_attribute: 'given val') %>"

          expect(render_view_template(view_template)).to eq(<<~eos)
            template some content

            given val

            more content
          eos
        end
      end

      context 'without attribute' do
        it 'uses the default value' do
          view_template = "template <%= #{component_class_name} %>"

          expect(render_view_template(view_template)).to eq(<<~eos)
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
      set_component_template(<<~eos)
        some content

        <%= block_content %>

        more content
      eos

      component_class.send(:redefine_method, :cache_key) do
        [attributes[:an_attribute], block_content]
      end
    end

    it 'works' do
      view_template = "template <%= #{component_class_name}(an_attribute: 'value') do %>content from block<% end %>"
      expect(render_view_template(view_template)).to eq(<<~eos)
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
