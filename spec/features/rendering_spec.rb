# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'rendering' do
  let(:component_class) do
    Class.new(Components::Rails::Component) do
      def cache_key
        [an_option, block_content]
      end

      def show
        render inline: <<~eos
          some content

          <%= an_option %>

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

      def an_option
        options[:an_option]
      end
      helper_method :an_option
    end
  end

  before { Object.const_set("My#{Time.now.subsec.numerator}Component", component_class) }

  it 'renders a component' do
    expect(component_class.render_action(:show, ActionView::Base.new, an_option: 'value')).to eq(<<~eos)
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
      component_class.new(nil, ActionView::Base.new, :show, an_option: :value, block: proc { 'the block' })
    end

    it 'works' do
      expect(subject.cache_key).to eq([:value, 'the block'])
    end
  end
end
