# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101122102315) do

  create_table "actions", :force => true do |t|
    t.string   "action"
    t.integer  "person_id"
    t.integer  "project_id"
    t.date     "creation_date"
    t.date     "due_date"
    t.string   "progress",      :limit => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "result"
    t.integer  "private",                    :default => 0
  end

  create_table "amendments", :force => true do |t|
    t.integer  "project_id"
    t.string   "responsible"
    t.string   "milestone",     :limit => 0
    t.string   "amendment"
    t.string   "action"
    t.date     "creation_date"
    t.integer  "done",                       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "centers", :force => true do |t|
    t.string   "name"
    t.integer  "supervisor_id"
    t.integer  "workstreamleader_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logs", :force => true do |t|
    t.string   "controller"
    t.string   "action"
    t.string   "controller_action"
    t.string   "browser"
    t.string   "ip"
    t.string   "session_id"
    t.integer  "person_id"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "milestones", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.date     "milestone_date"
    t.date     "actual_milestone_date"
    t.integer  "status"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "done",                  :default => 0
  end

  create_table "people", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rmt_user"
    t.integer  "is_supervisor", :default => 0
    t.string   "login"
    t.string   "pwd"
  end

  create_table "person_roles", :force => true do |t|
    t.integer  "person_id"
    t.integer  "role_id"
    t.datetime "created_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "brn"
    t.string   "workstream"
    t.integer  "project_id"
    t.integer  "last_status",   :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supervisor_id"
    t.string   "coordinator"
    t.string   "pm"
    t.string   "bpl"
    t.string   "ispl"
  end

# Could not dump table "requests" because of following ActiveRecord::StatementInvalid
#   Mysql::Error: Can't create/write to file 'C:\TEMP\#sql_784_0.MYI' (Errcode: 13): describe `requests`

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "statuses", :force => true do |t|
    t.integer  "project_id",                       :null => false
    t.integer  "status",            :default => 0
    t.text     "explanation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "feedback"
    t.text     "reason"
    t.text     "operational_alert"
    t.text     "last_change"
    t.text     "actions"
    t.string   "ereporting_date"
    t.text     "explanation_diffs"
    t.text     "last_change_diffs"
  end

end
