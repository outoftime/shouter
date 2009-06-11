class Comment < ActiveRecord::Base
  shout :commented, :on => :create,
                    :target => :commentable,
                    :actor => :user,
                    :owners => proc { |comment| comment.commentable.users }

  belongs_to :commentable, :polymorphic => true
  belongs_to :user
end
