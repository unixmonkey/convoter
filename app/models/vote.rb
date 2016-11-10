class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :talk

  after_create_commit do
    VoteJob.perform_now(user_id, talk_id)
  end
end
