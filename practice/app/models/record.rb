
class RecordValidator < ActiveModel::Validator
  def validate(record)
    if record.teamid == nil or record.teamid > MyConstants::TOTAL_TEAMS
      record.errors[:base] << "Invalid team ID"
    end

    if record.chalid == nil or record.chalid > MyConstants::TOTAL_CHALLENGES
      record.errors[:base] << "Invalid challenge ID"
    end
  end
end

class Record < ApplicationRecord
    validates :teamid, numericality: {only_integer: true}, presence: true
    validates :chalid, numericality: {only_integer: true}, presence: true
    validates :answer, presence: true
    validates_with RecordValidator
end
