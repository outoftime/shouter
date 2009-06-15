%w(models).each do |dir|
  ActiveSupport::Dependencies.load_paths <<
    File.join(File.dirname(__FILE__), 'app', dir)
end

module Shouter
  class <<self
    def included(base)
      base.module_eval { extend Shouter::ActsAsMethods }
    end

    def proc_call(object, block)
      if block.respond_to?(:call)
        block.call(object)
      else
        object.send(block)
      end
    end
  end

  module ActsAsMethods
    def shout(event_name, options = {})
      lifecycle_event = options[:on] ||
        raise(ArgumentError, ":on option must be provided for shout")
      send("after_#{lifecycle_event}") do |shoutable|
        Shouter::EventBuilder.build(shoutable, event_name, options)
      end
      if options[:copy_fields] && options[:on].to_sym == :create
        before_update do |shoutable|
          update_attributes = {}
          options[:copy_fields].each do |copy_field|
            update_attributes[copy_field] = shoutable.send(copy_field)
          end
          Shouter::Event.for_target(shoutable).named(event_name).each do |event|
            event.update_attributes!(update_attributes)
          end
        end
      end
    end
  end
end
