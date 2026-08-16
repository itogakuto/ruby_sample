class CreateSprints < ActiveRecord::Migration[8.1]
  def change
    create_table :sprints do |t|
      t.text :customer_value_hypothesis
      t.text :validation_method
      t.text :validation_result
      t.text :learning
      t.text :next_action
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
