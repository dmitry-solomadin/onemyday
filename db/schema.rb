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

ActiveRecord::Schema.define(:version => 20120901104737) do

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.string   "oauth_secret"
  end

  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "comments", :force => true do |t|
    t.text     "text"
    t.integer  "story_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "comment_id"
    t.integer  "user_id"
  end

  add_index "comments", ["comment_id"], :name => "index_comments_on_comment_id"
  add_index "comments", ["story_id"], :name => "index_comments_on_story_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "likes", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "story_id"
  end

  add_index "likes", ["story_id"], :name => "index_likes_on_story_id"
  add_index "likes", ["user_id"], :name => "index_likes_on_user_id"

  create_table "stories", :force => true do |t|
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "title"
    t.datetime "date"
    t.integer  "user_id"
    t.integer  "type_cd"
    t.boolean  "published",  :default => false
  end

  add_index "stories", ["user_id"], :name => "index_stories_on_user_id"

  create_table "story_photos", :force => true do |t|
    t.integer  "order"
    t.integer  "story_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "caption"
    t.datetime "date"
    t.integer  "orientation_cd"
    t.string   "photo_dimensions"
    t.string   "time_taken"
  end

  add_index "story_photos", ["story_id"], :name => "index_story_photos_on_story_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "email"
    t.string   "job_title"
    t.string   "company"
  end

  create_table "views", :force => true do |t|
    t.datetime "date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "story_id"
  end

  add_index "views", ["story_id"], :name => "index_views_on_story_id"

end
