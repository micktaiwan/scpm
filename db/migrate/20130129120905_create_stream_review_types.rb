class CreateStreamReviewTypes < ActiveRecord::Migration
  def self.up
    create_table :stream_review_types do |t|
      t.integer  :stream_id
      t.integer  :review_type_id
      t.timestamps
    end
  end

  def self.down
    drop_table :stream_review_types
  end
end
