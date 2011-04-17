module ActiveRecord
  class Base
    def update_attribute; end
    def save; end
  end
end

require 'do_not_want'
require 'gems/fake_gem'

describe 'do not want' do
  let(:model_object) { ActiveRecord::Base.new }

  it "raises an error for unwanted method calls" do
    expect do
      model_object.update_attribute(:attribute, :value)
    end.to raise_error(DoNotWant::NotSafe)
  end

  it "lets other methods through" do
    model_object.class.should == ActiveRecord::Base
  end

  context "caller filtering" do
    it "ignores calls from gems" do
      expect do
        call_activerecord_update_attribute
      end.not_to raise_error
    end
  end
end

