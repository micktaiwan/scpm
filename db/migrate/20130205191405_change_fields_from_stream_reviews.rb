class ChangeFieldsFromStreamReviews < ActiveRecord::Migration
    def self.up
    	add_column :stream_reviews, :author_id, :integer
    	add_column :stream_reviews, :text_diff, :text
    end

    def self.down
      drop_table :stream_reviews
    end
end
