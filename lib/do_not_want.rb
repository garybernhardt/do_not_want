module DoNotWant
  BAD_INSTANCE_METHODS = {
    :decrement => [:callbacks],
    :decrement! => [:validation],
    :increment => [:callbacks],
    :increment! => [:validation],
    :toggle => [:callbacks],
    :toggle! => [:validation],
    :update_attribute => [:validation],
  }
  BAD_INSTANCE_METHOD_NAMES = BAD_INSTANCE_METHODS.keys

  BAD_CLASS_METHODS = {
    :decrement_counter => [:validation, :callbacks],
    :delete => [:callbacks],
    :delete_all => [:callbacks],
    :find_by_sql => [:callbacks],
    :increment_counter => [:validation, :callbacks],
    :update_all => [:validation, :callbacks],
    :update_counters => [:validation, :callbacks],
  }
  BAD_CLASS_METHOD_NAMES = BAD_CLASS_METHODS.keys

  class NotSafe < Exception
    def initialize(called_class, called_method, reason)
      class_name = called_class.name
      method_name = called_method.to_s
      super "%s#%s isn't safe because %s" % [
        class_name,
        method_name,
        reason
      ]
    end
  end

  def self.should_validate_for_caller(caller)
    /\/gems\//.match(caller[0])
  end
end

class Object
  def self.do_not_want!(method_name, reason)
    original_method_name = ('do_not_want_original_' + method_name.to_s).to_sym
    self.send :alias_method, original_method_name, method_name

    self.send :define_method, method_name do |*args|
      original_method_name = ('do_not_want_original_' + method_name.to_s).to_sym
      use_real_method = DoNotWant.should_validate_for_caller(caller)
      if use_real_method
        return self.send original_method_name, *args
      end
      raise DoNotWant::NotSafe.new(self.class, method_name, reason)
    end
  end
end

module ActiveRecord
  class Base

    DoNotWant::BAD_INSTANCE_METHODS.each do |method_name, reasons|
      do_not_want!(method_name, 'it skips validation')
    end

    class << self
      DoNotWant::BAD_CLASS_METHODS.each do |method_name, reasons|
        do_not_want!(method_name, 'it skips validation')
      end
    end
  end
end

