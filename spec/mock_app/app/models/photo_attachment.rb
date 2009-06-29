class PhotoAttachment < ActiveRecord::Base
  belongs_to :photo
  belongs_to :target, :polymorphic => true
  belongs_to :user

  shout :photo_attached, :subject => :photo,
                         :target => :target,
                         :group => 15.minutes
end
