class Link < ActiveRecord::Base
  belongs_to :source, :polymorphic => true
  belongs_to :target, :polymorphic => true

  shout :post_linked, :group => true,
                      :subject => :target,
                      :target => :source
end
