module Shouter
  class EventOwnerAttachment < ActiveRecord::Base
    TABLE_NAME = 'shouter_event_owner_attachments'

    class <<self
      def table_name
        TABLE_NAME
      end
    end

    belongs_to :event, :class_name => 'Shouter::Event'
    belongs_to :owner, :polymorphic => true
  end
end
