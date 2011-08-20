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
end


