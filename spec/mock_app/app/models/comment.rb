class Comment < ActiveRecord::Base
  shout :commented, :target => :commentable,
                    :actor => :user,
                    :owners => proc { |comment| comment.commentable.users }

  belongs_to :commentable, :polymorphic => true
  belongs_to :user
end
