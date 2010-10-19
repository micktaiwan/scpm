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

ActiveRecord::Schema.define(:version => 20101019085015) do

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

  create_table "people", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rmt_user"
    t.integer  "is_supervisor", :default => 0
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
  end

  create_table "requests", :force => true do |t|
    t.string   "request_id"
    t.string   "workstream"
    t.string   "status"
    t.string   "assigned_to"
    t.string   "resolution"
    t.string   "updated"
    t.string   "reporter"
    t.string   "view_status"
    t.string   "milestone"
    t.string   "priority"
    t.string   "summary"
    t.string   "date_submitted"
    t.string   "product_version"
    t.string   "severity"
    t.string   "platform"
    t.string   "work_package"
    t.string   "complexity"
    t.string   "start_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sdp"
    t.string   "pm"
    t.string   "milestone_date"
    t.string   "project_name"
    t.string   "actual_m_date"
    t.string   "end_date"
    t.integer  "project_id"
  end

  add_index "requests", ["request_id"], :name => "index_requests_on_request_id"

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
  end

end
