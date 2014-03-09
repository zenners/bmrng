class Answer < ActiveRecord::Base
  belongs_to :guest
  belongs_to :question
end
