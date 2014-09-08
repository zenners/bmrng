class Answer < ActiveRecord::Base
  belongs_to :guest
  belongs_to :question

  attr_accessible :guest, :question, :content
end
