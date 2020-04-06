# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_02_23_233013) do

  create_table "storage_games", force: :cascade do |t|
    t.string "external_id", null: false
    t.string "snake_version", null: false
    t.text "initial_state", null: false
    t.boolean "victory"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "storage_moves", force: :cascade do |t|
    t.integer "game_id"
    t.integer "turn"
    t.string "snake_version"
    t.string "decision"
    t.text "state"
    t.text "evaluations"
    t.decimal "runtime", precision: 15, scale: 9
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_storage_moves_on_game_id"
  end

end
