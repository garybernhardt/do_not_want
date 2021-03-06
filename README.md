# Do Not Want

* http://github.com/garybernhardt/do_not_want

## DESCRIPTION:

Several methods in ActiveRecord skip validations, callbacks, or both. In my extremely humble but also extremely correct opinion, it's too easy to accidentally use these.

Do Not Want kills those methods dead so you won't cut yourself on them:

    >> User.new.update_attribute(:foo, 5)
    DoNotWant::NotSafe: User#update_attribute isn't safe because it skips validation

## Why Do It Do It?

In my experience, even experienced Rails developers don't know which ActiveRecord methods skip validations and callbacks. Quick: which of `decrement`, `decrement!`, and `decrement_counter` skip which? (Hint: they're all different.)

## How Do It Do It?

It `define_method`s them away.

But! Calls to the unsafe methods are allowed from within gems. This keeps Rails from breaking, and allows third-party code to do as it pleases while keeping your app as jank-free as possible.

The disabled instance methods are:

    decrement
    decrement!
    increment
    increment!
    toggle
    toggle!
    update_attribute

The disabled class methods are:

    decrement_counter
    delete
    delete_all
    find_by_sql
    increment_counter
    update_all
    update_counters

The particular transgressions that these methods make are documented in the source.

The Rails [ActiveRecord guide](http://guides.rubyonrails.org/active_record_callbacks.html#skipping-callbacks) contains lists of methods that skip validation and callbacks. That's where this list came from.

## Should I Use This?

**No!** Tracking the list of unsafe methods in different versions of Rails is too large a task to be worth it. Instead, you should be very careful about which methods you use in production systems.

The Rails team maintains a list of methods that skip callbacks (see "Skipping Callbacks" in the [callback guide](http://guides.rubyonrails.org/active_record_callbacks.html#skipping-callbacks)) and a list of methods that skip validations (see "Skipping Validations" in the [validations guide](http://guides.rubyonrails.org/active_record_validations.html#skipping-validations)). All of these methods should be avoided during normal Rails application development.
