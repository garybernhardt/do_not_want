class Object
  def self.do_not_want!(method_name, reason)
    original_method_name = ('do_not_want_original_' + method_name.to_s).to_sym
    self.send :alias_method, original_method_name, method_name

    self.send :define_method, method_name do |*args|
      original_method_name = ('do_not_want_original_' + method_name.to_s).to_sym
      use_real_method = DoNotWant.should_validate_for_caller(caller)
      if use_real_method
        self.send original_method_name, *args
      end
      raise DoNotWant::NotSafe.new(self.class, method_name, reason)
    end
  end
end

module ActiveRecord
  class Base
    do_not_want!(:update_attribute, 'it skips validation')
    do_not_want!(:save, 'it skips validation')
  end
end

module DoNotWant
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

