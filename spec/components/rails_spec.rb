require "spec_helper"

RSpec.describe Components::Rails do
  it "has a version number" do
    expect(Components::Rails::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
