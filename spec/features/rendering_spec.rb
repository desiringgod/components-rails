# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'rendering' do
  let(:component_class) do
    Class.new(Components::Rails::Component) do
      def cache_key
        [attributes[:an_attribute], block_content]
      end

      def show
        render inline: <<~eos
          some content

          <%= an_attribute %>

          more content
        eos
      end

      def index
        render inline: <<~eos
          some content

          <%= block_content %>

          more content
        eos
      end
    end
  end

  before { Object.const_set("My#{Time.now.subsec.numerator}Component", component_class) }

  it 'renders a component' do
    expect(component_class.render_action(:show, ActionView::Base.new, an_attribute: 'value')).to eq(<<~eos)
      some content

      value

      more content
    eos
  end

  it 'renders a component with a block' do
    expect(component_class.render_action(:index, ActionView::Base.new) do
      'content from block'
    end).to eq(<<~eos)
      some content

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

  describe 'attributes with default value' do
    let(:component_class) do
      Class.new(Components::Rails::Component) do
        attribute :some_attribute, default: 'default value'

        def cache_key
          '123'
        end

        def show
          render inline: <<~eos
            some content

            <%= attributes[:some_attribute] %>

            more content
          eos
        end
      end
    end

    context 'with attribute' do
      it 'uses the value' do
        expect(component_class.render_action(:show, ActionView::Base.new, some_attribute: 'given val')).to eq(<<~eos)
          some content

          given val

          more content
        eos
      end
    end

    context 'without attribute' do
      it 'uses the default value' do
        expect(component_class.render_action(:show, ActionView::Base.new)).to eq(<<~eos)
          some content

          default value

          more content
        eos
      end
    end
  end
end
