class Post < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :photo_attachments, :as => :target

  shout :post_created, :on => :create,
                       :actors => :users,
                       :copy_fields => [:published_at]

  def photos
    photo_attachments.map { |attachment| attachment.photo }
  end

  def new_photo(user)
    attachment = photo_attachments.create! do |attachment|
      attachment.target = self
      attachment.photo = Photo.new
    end
    attachment.photo
  end
end
