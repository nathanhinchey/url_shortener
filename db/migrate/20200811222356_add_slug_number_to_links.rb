class AddSlugNumberToLinks < ActiveRecord::Migration[6.0]
  def change
    add_column :links, :slug_number, :integer
  end
end
