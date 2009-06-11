module Shouter
  class EventActorAttachment < ActiveRecord::Base
    TABLE_NAME = 'shouter_event_actor_attachments'

    class <<self
      def table_name
        TABLE_NAME
      end
    end

    belongs_to :event, :class_name => 'Shouter::Event'
    belongs_to :actor, :polymorphic => true
  end
end
