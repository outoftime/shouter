%w(models).each do |dir|
  ActiveSupport::Dependencies.load_paths <<
    File.join(File.dirname(__FILE__), 'app', dir)
end

module Shouter
  class <<self
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
      unless is_a?(ClassMethods)
        has_many :shouter_events, :class_name => 'Shouter::Event', :as => :target
        extend(ClassMethods)
        include(InstanceMethods)
      end
      after_create do |shoutable|
        Shouter::EventBuilder.build(shoutable, event_name, options)
      end
      if options[:copy_fields]
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

  module ClassMethods
  end

  module InstanceMethods
    def last_activity_at
      shouter_events.first(
        :select => 'shouter_events.updated_at',
        :order => 'updated_at DESC'
      ).updated_at
    end
  end
end
