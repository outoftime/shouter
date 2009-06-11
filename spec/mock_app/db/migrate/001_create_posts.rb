class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts, :force => true do |t|
      t.string :headline
      t.datetime :published_at
    end
  end

  def self.down
    drop_table :posts
  end
end
