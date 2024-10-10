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

ActiveRecord::Schema[7.0].define(version: 2024_06_04_211114) do
  create_table "answers", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "question_id"
    t.text "text"
    t.text "short_text"
    t.text "help_text"
    t.integer "weight"
    t.string "response_class"
    t.string "reference_identifier"
    t.string "data_export_identifier"
    t.string "common_namespace"
    t.string "common_identifier"
    t.integer "display_order"
    t.boolean "is_exclusive"
    t.integer "display_length"
    t.string "custom_class"
    t.string "custom_renderer"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "default_value"
    t.string "api_id"
    t.string "display_type"
    t.string "input_mask"
    t.string "input_mask_placeholder"
    t.string "original_choice"
    t.boolean "is_comment", default: false
    t.integer "column_id"
    t.index ["api_id"], name: "uq_answers_api_id", unique: true
  end

  create_table "columns", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "question_group_id"
    t.text "text"
    t.text "answers_textbox"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "dependencies", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "question_id"
    t.integer "question_group_id"
    t.string "rule"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "dependency_conditions", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "dependency_id"
    t.string "rule_key"
    t.integer "question_id"
    t.string "operator"
    t.integer "answer_id"
    t.datetime "datetime_value", precision: nil
    t.integer "integer_value"
    t.float "float_value"
    t.string "unit"
    t.text "text_value"
    t.string "string_value"
    t.string "response_other"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "column_id"
  end

  create_table "question_groups", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.text "text"
    t.text "help_text"
    t.string "reference_identifier"
    t.string "data_export_identifier"
    t.string "common_namespace"
    t.string "common_identifier"
    t.string "display_type"
    t.string "custom_class"
    t.string "custom_renderer"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "api_id"
    t.index ["api_id"], name: "uq_question_groups_api_id", unique: true
  end

  create_table "questions", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "survey_section_id"
    t.integer "question_group_id"
    t.text "text"
    t.text "short_text"
    t.text "help_text"
    t.string "pick"
    t.string "reference_identifier"
    t.string "data_export_identifier"
    t.string "common_namespace"
    t.string "common_identifier"
    t.integer "display_order"
    t.string "display_type"
    t.boolean "is_mandatory"
    t.integer "display_width"
    t.string "custom_class"
    t.string "custom_renderer"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "correct_answer_id"
    t.string "api_id"
    t.boolean "modifiable", default: true
    t.boolean "dynamically_generate", default: false
    t.string "dummy_blob"
    t.string "dynamic_source"
    t.string "report_code"
    t.boolean "is_comment", default: false
    t.text "correct_feedback"
    t.text "incorrect_feedback"
    t.index ["api_id"], name: "uq_questions_api_id", unique: true
  end

  create_table "response_sets", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "user_id"
    t.integer "survey_id"
    t.string "access_code"
    t.datetime "started_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "api_id"
    t.boolean "test_data", default: false
    t.index ["access_code"], name: "response_sets_ac_idx", unique: true
    t.index ["api_id"], name: "uq_response_sets_api_id", unique: true
  end

  create_table "responses", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "response_set_id"
    t.integer "question_id"
    t.integer "answer_id"
    t.datetime "datetime_value", precision: nil
    t.integer "integer_value"
    t.float "float_value"
    t.string "unit"
    t.text "text_value"
    t.string "string_value"
    t.string "response_other"
    t.string "response_group"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "survey_section_id"
    t.string "api_id"
    t.string "blob"
    t.integer "column_id"
    t.index ["api_id"], name: "uq_responses_api_id", unique: true
    t.index ["survey_section_id"], name: "index_responses_on_survey_section_id"
  end

  create_table "rows", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "question_group_id"
    t.string "text"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "survey_sections", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "survey_id"
    t.string "title"
    t.text "description"
    t.string "reference_identifier"
    t.string "data_export_identifier"
    t.string "common_namespace"
    t.string "common_identifier"
    t.integer "display_order"
    t.string "custom_class"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "modifiable", default: true
  end

  create_table "survey_translations", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "survey_id"
    t.string "locale"
    t.text "translation"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "surveys", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "access_code"
    t.string "reference_identifier"
    t.string "data_export_identifier"
    t.string "common_namespace"
    t.string "common_identifier"
    t.datetime "active_at", precision: nil
    t.datetime "inactive_at", precision: nil
    t.string "css_url"
    t.string "custom_class"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "display_order"
    t.string "api_id"
    t.integer "survey_version", default: 0
    t.boolean "template", default: false
    t.integer "user_id"
    t.string "internal_title"
    t.boolean "quiz", default: false
    t.boolean "public", default: false
    t.index ["access_code", "survey_version"], name: "surveys_access_code_version_idx", unique: true
    t.index ["api_id"], name: "uq_surveys_api_id", unique: true
  end

  create_table "validation_conditions", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "validation_id"
    t.string "rule_key"
    t.string "operator"
    t.integer "question_id"
    t.integer "answer_id"
    t.datetime "datetime_value", precision: nil
    t.integer "integer_value"
    t.float "float_value"
    t.string "unit"
    t.text "text_value"
    t.string "string_value"
    t.string "response_other"
    t.string "regexp"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "validations", id: :integer, charset: "utf8mb3", force: :cascade do |t|
    t.integer "answer_id"
    t.string "rule"
    t.string "message"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

end
