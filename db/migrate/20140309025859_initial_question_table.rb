class InitialQuestionTable < ActiveRecord::Migration
  def change
    create_table :questions, force: true do |q|
      q.integer :user_id
      q.text    :content
      q.timestamps
    end
  end
end
