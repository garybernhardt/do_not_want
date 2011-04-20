require 'active_record'
require 'do_not_want'
require 'gems/fake_gem'

class Walrus
  def be_killed_by!(killer, reason)
    die!
    "killed by #{killer} because #{reason}"
  end

  def die!
  end

  do_not_want! :be_killed_by!, 'because dying sucks'
end

describe 'do not want' do
  let(:walrus) { Walrus.new }

  it "raises an error for unwanted method calls" do
    walrus.should_not_receive(:die!)
    expect do
      walrus.be_killed_by!
    end.to raise_error(DoNotWant::NotSafe)
  end

  it "lets other methods through" do
    walrus.class.should == Walrus
  end

  context "caller filtering" do
    it "ignores calls from gems" do
      walrus.should_receive(:die!)
      expect do
        kill_walrus(walrus)
      end.not_to raise_error
    end

    it "passes arguments" do
      kill_walrus(walrus).should == 'killed by kitty because kitty is angry'
    end
  end
end

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:")

ActiveRecord::Base.connection.create_table(:cheeses) do |t|
  t.string :name
end

class Cheese < ActiveRecord::Base
end

describe 'rails integration' do
  let(:cheese) { Cheese.create! }
  it 'rejects unsafe instance methods' do
    DoNotWant::RAILS_INSTANCE_METHOD_THAT_SKIP_VALIDATION.each do |method_name|
      expect do
        cheese.send method_name
      end.to raise_error DoNotWant::NotSafe
    end
  end

  it 'allows safe instance methods' do
    cheese.reload
  end
end

