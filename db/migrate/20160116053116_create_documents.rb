class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.integer :qid
      t.text :vector
      t.integer :grade

      t.timestamps null: false
    end
  end
end
