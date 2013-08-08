# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130621233130) do

  create_table "entries", :force => true do |t|
    t.integer  "tiebreak"
    t.string   "status"
    t.integer  "user_id"
    t.integer  "week_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "entries", ["user_id"], :name => "index_entries_on_user_id"
  add_index "entries", ["week_id", "user_id"], :name => "index_entries_on_week_id_and_user_id", :unique => true

  create_table "games", :force => true do |t|
    t.integer  "week_id"
    t.string   "status"
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.integer  "home_points"
    t.integer  "away_points"
    t.datetime "start"
    t.boolean  "tiebreak"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "games", ["away_team_id"], :name => "index_games_on_away_team_id"
  add_index "games", ["home_team_id"], :name => "index_games_on_home_team_id"
  add_index "games", ["week_id"], :name => "index_games_on_week_id"

  create_table "microposts", :force => true do |t|
    t.string   "content"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "picks", :force => true do |t|
    t.integer  "entry_id"
    t.integer  "game_id"
    t.string   "pick"
    t.integer  "points"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "picks", ["entry_id", "game_id"], :name => "index_picks_on_entry_id_and_game_id", :unique => true
  add_index "picks", ["game_id"], :name => "index_picks_on_game_id"

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], :name => "index_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "seasons", :force => true do |t|
    t.integer  "year"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "seasons", ["year"], :name => "index_seasons_on_year", :unique => true

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.string   "nickname"
    t.string   "code"
    t.string   "city"
    t.string   "image_file_name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "teams", ["code"], :name => "index_teams_on_code", :unique => true
  add_index "teams", ["name"], :name => "index_teams_on_name", :unique => true
  add_index "teams", ["nickname"], :name => "index_teams_on_nickname", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "weeks", :force => true do |t|
    t.integer  "week_num"
    t.integer  "season_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "weeks", ["season_id", "week_num"], :name => "index_weeks_on_season_id_and_week_num", :unique => true

end
