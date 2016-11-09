class VoteJob < ApplicationJob
  queue_as :default

  def perform(user_id, talk_id)
    puts user_id, talk_id
    talk = Vote.find_by(user_id: user_id, talk_id: talk_id).talk
    puts "talk: #{talk.inspect}"
    ActionCable.server.broadcast "votes_#{user_id}_channel",
      message: 'votes_updated',
      talk_id: talk_id,
      html: "(#{talk.votes.count} going)"
  end
end
