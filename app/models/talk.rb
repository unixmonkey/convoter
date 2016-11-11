class Talk < ApplicationRecord
  belongs_to :slot
  has_many :votes

  default_scope { order(created_at: :asc) }

  def voter_names
    votes.includes(:user).map { |vote| vote.user.name }.uniq.sort.to_sentence
  end
end
