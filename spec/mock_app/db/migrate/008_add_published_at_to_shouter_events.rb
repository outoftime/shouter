class AddPublishedAtToShouterEvents < ActiveRecord::Migration
  def self.up
    add_column :shouter_events, :published_at, :datetime
  end

  def self.down
    remove_column :shouter_events, :published_at, :datetime
  end
end
