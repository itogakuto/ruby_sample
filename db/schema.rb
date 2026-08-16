# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_15_072442) do
  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "sprints", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "customer_value_hypothesis"
    t.text "learning"
    t.text "next_action"
    t.integer "project_id", null: false
    t.datetime "updated_at", null: false
    t.text "validation_method"
    t.text "validation_result"
    t.index ["project_id"], name: "index_sprints_on_project_id"
  end

  add_foreign_key "sprints", "projects"
end
