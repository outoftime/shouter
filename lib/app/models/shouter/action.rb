module Shouter
  class Action < ActiveRecord::Base
    TABLE_NAME = 'shouter_actions'

    class <<self
      def table_name
        TABLE_NAME
      end
    end

    belongs_to :subject, :polymorphic => true
  end
end
