class CreateJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :jobs do |t|
      t.string :title
      t.text :description
      t.boolean :done, default: false
      t.datetime :deadline
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
