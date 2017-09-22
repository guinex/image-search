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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170824065251) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cluster_relations", force: :cascade do |t|
    t.string   "cluster_id"
    t.string   "relation_type"
    t.integer  "grade"
    t.integer  "z_distance"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "related_id"
  end

  create_table "color_clusters", force: :cascade do |t|
    t.string   "color_hash_percent"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.text     "gray_scaled"
    t.text     "color_scaled"
    t.integer  "category_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "failed_images", force: :cascade do |t|
    t.string   "image_id"
    t.integer  "failed_count", default: 1
    t.string   "state",        default: "waiting"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "image_colors", force: :cascade do |t|
    t.string "color_hex",  null: false
    t.string "color_name"
  end

  create_table "image_searches", force: :cascade do |t|
    t.string  "fingerprint"
    t.string  "design_id"
    t.string  "image_id"
    t.binary  "phash_obj"
    t.text    "color_histogram"
    t.string  "cluster_id"
    t.integer "category_id"
    t.index ["design_id"], name: "index_image_searches_on_design_id", using: :btree
    t.index ["fingerprint"], name: "index_image_searches_on_fingerprint", using: :btree
  end

  create_table "images", force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "fingerprint"
    t.text     "design_ids"
    t.datetime "processed_for_duplicate_at"
    t.datetime "processed_for_similar_at"
    t.text     "similar_designs"
  end

  create_table "manage_catalogs", force: :cascade do |t|
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "design_id"
    t.string   "geo"
    t.string   "processing_state", default: "waiting"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
    t.index ["name"], name: "index_roles_on_name", using: :btree
  end

  create_table "subapps", force: :cascade do |t|
    t.string   "appname",     default: "", null: false
    t.string   "description"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "system_constants", id: :integer, default: -> { "nextval('system_constant_id_seq'::regclass)" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "name"
    t.text     "value"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree
  end

end
