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

ActiveRecord::Schema[7.0].define(version: 2023000005) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "eliminations", id: :string, force: :cascade do |t|
    t.string "name"
    t.string "tournament_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_eliminations_on_tournament_id"
  end

  create_table "games", id: :string, force: :cascade do |t|
    t.string "tournament_id", null: false
    t.integer "round"
    t.integer "gameNo"
    t.string "a_team_id"
    t.string "b_team_id"
    t.string "win_team_id"
    t.string "lose_team_id"
    t.string "a_result", limit: 4
    t.string "b_result", limit: 4
    t.string "a_score", limit: 16
    t.string "b_score", limit: 16
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_games_on_tournament_id"
  end

  create_table "roundrobins", id: :string, force: :cascade do |t|
    t.string "name"
    t.string "tournament_id", null: false
    t.integer "num_of_round", default: 1
    t.integer "rank1", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_roundrobins_on_tournament_id"
  end

  create_table "teams", id: :string, force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.integer "entryNo"
    t.string "tournament_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_teams_on_tournament_id"
  end

  create_table "tournaments", id: :string, force: :cascade do |t|
    t.integer "tournament_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "eliminations", "tournaments"
  add_foreign_key "games", "tournaments"
  add_foreign_key "roundrobins", "tournaments"
  add_foreign_key "teams", "tournaments"
end
