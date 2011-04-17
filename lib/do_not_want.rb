class Object
  def self.do_not_want!(method_name, reason)
    @@do_not_want_original_methods ||= {}
    @@do_not_want_original_methods[method_name] = instance_method(method_name)
    self.send :define_method, method_name do
      if DoNotWant.should_ignore_caller(caller)
        return @@do_not_want_original_methods[method_name].bind(self).call
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

  def self.should_ignore_caller(caller)
    /\/gems\//.match(caller[0])
  end
end

