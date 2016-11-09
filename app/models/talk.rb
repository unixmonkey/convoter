class Talk < ApplicationRecord
  belongs_to :slot
  has_many :votes

  def voter_names
    votes.includes(:user).map { |vote| vote.user.name }.uniq.sort.to_sentence
  end
end
