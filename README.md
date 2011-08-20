Do Not Want
-----------

To install:

    gem install donotwant

What It Do
----------

Several methods in ActiveRecord skip validations, callbacks, or both. In my extremely humble but also extremely correct opinion, this is a bad idea.

Do Not Want kills those methods dead so you won't cut yourself on them.

Why Do It Do It
---------------

In my experience, even experienced Rails developers don't know which of these methods skip validations and callbacks. Quick: which of `decrement`, `decrement!`, and `decrement_counter` skip which? (Hint: they're all different.)

How Do It Do It
---------------

It `define_method`s them away.

But! It also keeps a handle to the original method around and calls to the unsafe methods are allowed from within gems. This keeps Rails from breaking, and allows existing jank to continue being janky while keeping your app as jank-free as possible.

The disabled instance methods are:

    :decrement
    :decrement!
    :increment
    :increment!
    :toggle
    :toggle!
    :update_attribute

The disabled class methods are:

    :decrement_counter
    :delete
    :delete_all
    :find_by_sql
    :increment_counter
    :update_all
    :update_counters

The particular transgressions that these methods make are documented in the source.

The Rails [ActiveRecord guide](http://guides.rubyonrails.org/active_record_validations_callbacks.html#skipping-validations) contains lists about methods that skip validation and callbacks. That's where this list came from.

