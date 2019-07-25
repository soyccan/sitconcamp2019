class AddSuccessfulToRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :successful, :boolean
  end
end
