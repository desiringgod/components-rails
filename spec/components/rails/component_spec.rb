require 'rails_helper'

RSpec::Matchers.define :a_partial_iteration_at_index do |index|
  match do |actual|
    actual.instance_of?(::ActionView::PartialIteration) && actual.index == index
  end
end

RSpec.describe Components::Rails::Component do
  subject { described_class.new(nil, :view, :action) }

  let(:subclass) { Class.new(described_class) }

  it { is_expected.to be_kind_of(::ActionView::Rendering) }
  it { is_expected.to be_kind_of(::AbstractController::Helpers) }
  it { is_expected.to be_kind_of(::AbstractController::Rendering) }
  it { is_expected.to be_kind_of(::AbstractController::Caching) }

  describe '#cache_key' do
    it 'raises an error' do
      expect(-> { subject.cache_key }).to raise_error(NotImplementedError)
    end
  end

  describe '#default_template' do
    context 'class is subclass of Component' do
      let(:component) { subclass.new(nil, :view, :show) }

      it 'returns the action' do
        expect(component.default_template).to eq('show')
      end
    end

    context 'class is Component' do
      let(:component) { described_class.new(nil, :view, :index, component: 'example') }

      it 'returns action with prefix of component option' do
        expect(component.default_template).to eq('example/index')
      end
    end
  end

  describe '#default_render' do
    before { allow(subject).to receive(:default_template).and_return(:template) }

    it 'renders the default_template' do
      expect(subject).to receive(:render).with(:template)
      subject.default_render
    end
  end

  describe '::render_action' do
    let(:view) { double(Object) }
    let(:component_instance) { described_class.new(nil, view, :action) }
    let(:view_context) { instance_double(::ActionView::Base) }

    before do
      allow(described_class).to receive(:new).and_return(component_instance)
      allow(component_instance).to receive(:render_to_body).and_return('rendered')
      allow(component_instance).to receive(:cache_key).and_return(:cache_key)
      described_class.send(:define_method, :the_action) {}
    end

    it 'calls the action' do
      expect(component_instance).to receive(:the_action)
      described_class.render_action('the_action', :view)
    end

    describe 'view rendering' do
      describe 'helpers' do
        before do
          described_class.send(:define_method, :a_helper) {}
          described_class.send(:helper_method, :a_helper)
        end

        it 'makes helpers available in rendering' do
          expect(described_class._helper_methods).to include(:a_helper)
        end

        it 'makes options available in rendering' do
          expect(described_class._helper_methods).to include(:options)
        end
      end

      context 'occurs in action' do
        before { described_class.send(:define_method, :generic_action) { render('view') } }

        it 'does not trigger default view rendering' do
          expect(component_instance).to receive(:render).with('view')
          expect(component_instance).not_to receive(:render).with('the_action')
          described_class.render_action('generic_action', :view)
        end
      end

      context 'does not occur in action' do
        it 'triggers default view rendering' do
          allow(component_instance).to receive(:default_template).and_return(:default_template)
          expect(component_instance).to receive(:render).with(:default_template)
          described_class.render_action('the_action', :view, component: :example)
        end
      end
    end

    context 'without object' do
      it 'instantiates a Component without an object' do
        expect(described_class).to receive(:new).with(nil, :view, :show, option: :value)
        described_class.render_action(:show, :view, option: :value)
      end

      it 'returns the response_body' do
        expect(described_class.render_action('render_action', :view)).to eq('rendered')
      end
    end

    context 'with object' do
      it 'instantiates a new Component with the object' do
        expect(described_class).to receive(:new).with(:object, :view, :index, option: :value)
        described_class.render_action(:index, :view, object: :object, option: :value)
      end

      it 'returns the response_body' do
        expect(described_class.render_action('render_action', :view, object: :object)).to eq('rendered')
      end
    end

    context 'with collection' do
      let(:collection) { %i[object1 object2 object3] }

      it 'instantiates a new Component for each item in the collection' do
        expect(described_class).to receive(:new)
          .with(:object1, :view, :action, option: :value, collection_iteration: a_partial_iteration_at_index(0))
          .ordered
        expect(described_class).to receive(:new)
          .with(:object2, :view, :action, option: :value, collection_iteration: a_partial_iteration_at_index(1))
          .ordered
        expect(described_class).to receive(:new)
          .with(:object3, :view, :action, option: :value, collection_iteration: a_partial_iteration_at_index(2))
          .ordered
        described_class.render_action(:action, :view, collection: collection, option: :value)
      end

      it 'returns the joined response_body values' do
        expect(described_class.render_action(:action, :view, collection: collection))
          .to eq('renderedrenderedrendered')
      end
    end
  end
end
