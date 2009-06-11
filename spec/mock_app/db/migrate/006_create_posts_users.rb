class CreatePostsUsers < ActiveRecord::Migration
  def self.up
    create_table :posts_users, :id => false, :force => true do |t|
      t.references :post
      t.references :user
    end
  end

  def self.down
    drop_table :posts_users
  end
end
