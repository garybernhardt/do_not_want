require 'active_record'
require 'do_not_want'

class Cheese < ActiveRecord::Base
end

describe 'rails integration' do
  before do
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database => ":memory:")

    ActiveRecord::Base.connection.create_table(:cheeses) do |t|
      t.string :name
    end
  end

  let(:cheese) { Cheese.create! }
  it 'rejects unsafe instance methods' do
    DoNotWant::BAD_INSTANCE_METHOD_NAMES.each do |method_name|
      expect do
        cheese.send method_name
      end.to raise_error DoNotWant::NotSafe
    end
  end

  it 'allows safe instance methods' do
    cheese.reload.should == cheese
  end

  it 'rejects unsafe class methods' do
    DoNotWant::BAD_CLASS_METHOD_NAMES.each do |method_name|
      expect { Cheese.send method_name }.to raise_error DoNotWant::NotSafe
    end
  end

  it 'allows safe class methods' do
    Cheese.columns.count.should == 2
  end

  it 'gives reasons' do
    expect { cheese.decrement }.to raise_error(
      DoNotWant::NotSafe,
      "Cheese#decrement isn't safe because it skips callbacks")
    expect { cheese.decrement! }.to raise_error(
      DoNotWant::NotSafe,
      "Cheese#decrement! isn't safe because it skips validation")
    expect { Cheese.update_all }.to raise_error(
      DoNotWant::NotSafe,
      "Cheese.update_all isn't safe because it skips validation and callbacks")
  end
end

