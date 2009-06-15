module Shouter
  class Event < ActiveRecord::Base
    TABLE_NAME = 'shouter_events'

    def self.table_name
      TABLE_NAME
    end

    belongs_to :target, :polymorphic => true
    has_many :event_actor_attachments,
             :class_name => 'Shouter::EventActorAttachment'
    has_many :event_owner_attachments,
             :class_name => 'Shouter::EventOwnerAttachment'
    has_many :actions, :class_name => 'Shouter::Action'

    before_save do |event|
      event.actors_cache = ActorsCache.generate(event.actors)
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
