class Link < ActiveRecord::Base
  belongs_to :source, :polymorphic => true
  belongs_to :target, :polymorphic => true

  shout :post_linked, :on => :create,
                      :group => true,
                      :subject => :target,
                      :target => :source
end
