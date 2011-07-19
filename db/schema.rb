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

ActiveRecord::Schema.define(:version => 20110719072246) do

  create_table "actions", :force => true do |t|
    t.text     "action"
    t.integer  "person_id"
    t.integer  "project_id"
    t.date     "creation_date"
    t.date     "due_date"
    t.string   "progress",      :limit => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "result"
    t.integer  "private",                    :default => 0
    t.integer  "origin_id",                  :default => 0
  end

  create_table "amendments", :force => true do |t|
    t.integer  "project_id"
    t.string   "responsible"
    t.string   "milestone"
    t.string   "amendment"
    t.string   "action"
    t.date     "duedate"
    t.integer  "done",        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bandeaus", :force => true do |t|
    t.text     "text"
    t.integer  "person_id"
    t.datetime "last_display"
    t.integer  "nb_displays",  :default => 0
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

# Could not dump table "chat_message_reads" because of following ActiveRecord::StatementInvalid
#   Mysql::Error: Can't create/write to file 'C:\TEMP\#sql_870_0.MYI' (Errcode: 13): describe `chat_message_reads`

