module DoNotWant
  RAILS_INSTANCE_METHOD_THAT_SKIP_VALIDATION = [
    :decrement!,
    :increment!,
    :toggle!,
    :update_attribute,
  ]
  RAILS_CLASS_METHODS_THAT_SKIP_VALIDATION = [
    :decrement_counter,
    :increment_counter,
    :update_all,
    :update_counters,
  ]
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

    DoNotWant::RAILS_INSTANCE_METHOD_THAT_SKIP_VALIDATION.each do |method_name|
      do_not_want!(method_name, 'it skips validation')
    end

    class << self
      DoNotWant::RAILS_CLASS_METHODS_THAT_SKIP_VALIDATION.each do |method_name|
        do_not_want!(method_name, 'it skips validation')
      end
    end
  end
end

