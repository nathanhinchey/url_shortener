class CreateLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :links do |t|
      t.string :target
      t.string :slug
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
