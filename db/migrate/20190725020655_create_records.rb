class CreateRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :records do |t|
      t.integer :teamid
      t.integer :chalid
      t.string :name
      t.string :answer
      t.string :diy

      t.timestamps
    end
  end
end
