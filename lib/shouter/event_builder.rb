module Shouter
  class EventBuilder
    class <<self
      def build(shoutable, event_name, options)
        new(shoutable, event_name, options).build
      end
    end

    def initialize(shoutable, event_name, options)
      @shoutable, @event_name, @options = shoutable, event_name, options
    end

    def build
      event = group_event || new_event
      if @options[:copy_fields]
        @options[:copy_fields].each do |copy_field|
          event.send("#{copy_field}=", @shoutable.send(copy_field))
        end
      end
      event.actions << Action.new do |action|
        action.subject = subject
      end
      event.save!
      event
    end

    private

    def subject
      @subject ||= 
        if subject_method = @options[:subject]
          Shouter.proc_call(@shoutable, subject_method)
        else
          @shoutable
        end
    end

    def target
      @target ||=
        if target_method = @options[:target]
          @shoutable.send(target_method)
        else
          @shoutable
        end
    end

    def actors
      @actors ||=
        if actors_method = @options[:actors] || @options[:actor]
          Shouter.proc_call(@shoutable, actors_method)
        end
    end

    def owners
      @owners ||=
        if owners_method = @options[:owners] || @options[:owner]
          Shouter.proc_call(@shoutable, owners_method)
        end
    end

    def new_event
      Shouter::Event.new do |e|
        e.name = @event_name.to_s
        e.target = target
        e.actors = actors if actors
        e.owners = owners if owners
      end
    end

    def group_event
      if grouped?
        conditions =
          ['name = ? AND target_type = ? AND target_id = ? and actors_cache = ?',
            @event_name.to_s,
            target.class.base_class.name,
            target.id,
            ActorsCache.generate(actors)]
        if group_expiration
          conditions.first << ' AND updated_at > ?'
          conditions << Time.now - group_expiration
        end
        Shouter::Event.last(
          :conditions => conditions,
          :order => 'updated_at DESC'
        )
      end
    end

    def grouped?
      @options[:group]
    end

    def group_expiration
      @options[:group] unless @options[:group] == true
    end
  end
end
