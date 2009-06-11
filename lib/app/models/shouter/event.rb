module Shouter
  class Event < ActiveRecord::Base
    TABLE_NAME = 'shouter_events'

    class <<self
      def table_name
        TABLE_NAME
      end

      def process(shoutable, event_name, options)
        subject =
          if subject_method = options[:subject]
            Shouter.proc_call(shoutable, subject_method)
          else
            shoutable
          end
        target = 
          if target_method = options[:target]
            shoutable.send(target_method)
          else
            shoutable
          end
        actors = 
          if actors_method = options[:actors] || options[:actor]
            Shouter.proc_call(shoutable, actors_method)
          end
        owners =
          if owners_method = options[:owners] || options[:owner]
            Shouter.proc_call(shoutable, owners_method)
          end
        event = if options[:group]
          conditions =
            ['name = ? AND target_type = ? AND target_id = ? and actors_cache = ?',
              event_name.to_s,
              target.class.base_class.name,
              target.id,
              generate_actors_cache(actors || [])]
          unless options[:group] == true
            conditions.first << ' AND updated_at > ?'
            conditions << Time.now - options[:group]
          end
          last(
            :conditions => conditions,
            :order => 'updated_at DESC'
          )
        end
        event ||= new do |e|
          e.name = event_name.to_s
          e.target = target
          e.actors = actors if actors
          e.owners = owners if owners
        end
        if options[:copy_fields]
          options[:copy_fields].each do |copy_field|
            event.send("#{copy_field}=", shoutable.send(copy_field))
          end
        end
        event.actions << Action.new do |action|
          action.subject = subject
        end
        event.save!
        event
      end

      def generate_actors_cache(actors)
        actors = [actors] unless actors.respond_to?(:map)
        actors.map do |author|
          "#{author.class.base_class.name}:#{author.id}"
        end.sort.join(' ')
      end
    end

    belongs_to :target, :polymorphic => true
    has_many :event_actor_attachments,
             :class_name => 'Shouter::EventActorAttachment'
    has_many :event_owner_attachments,
             :class_name => 'Shouter::EventOwnerAttachment'
    has_many :actions, :class_name => 'Shouter::Action'

    before_save do |event|
      event.actors_cache = Event.generate_actors_cache(event.actors)
    end

    named_scope(:named, lambda { |name| { :conditions => { :name => name.to_s }}})
    named_scope(:for_target, lambda do |shoutable|
      {
        :conditions => {
          :target_id => shoutable.id,
          :target_type => shoutable.class.base_class.name
        }
      }
    end)

    %w(actor owner).each do |relation|
      module_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def #{relation}s(reload = false)
          @#{relation}s = nil if reload
          @#{relation}s ||=
            begin
              event_#{relation}_attachments = self.event_#{relation}_attachments
              Event#{relation.capitalize}Attachment.module_eval do
                preload_associations(
                  event_#{relation}_attachments,
                  :#{relation}
                )
              end
              event_#{relation}_attachments.map do |attachment|
                attachment.#{relation}
              end
            end
        end

        def #{relation}s=(#{relation}s)
          #{relation}s = [#{relation}s] unless #{relation}s.respond_to?(:map)
          self.event_#{relation}_attachments = #{relation}s.map do |#{relation}|
            Event#{relation.capitalize}Attachment.new do |attachment|
              attachment.event = self
              attachment.#{relation} = #{relation}
            end
          end
        end
      RUBY
    end
  end
end
