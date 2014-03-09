class InitialAnswerTable < ActiveRecord::Migration
  def change
    create_table :answers, force: true do |a|
      a.integer  :question_id
      a.text   :content
      a.integer :guest_id
      a.timestamps
    end
  end
end
