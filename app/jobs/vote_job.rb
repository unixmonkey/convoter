class VoteJob < ApplicationJob
  queue_as :default

  def perform(user_id, talk_id)
    vote = Vote.find_by(user_id: user_id, talk_id: talk_id)
    talk = vote.talk
    html = ConferencesController.render talk,
      locals: { current_user: vote.user }
    ActionCable.server.broadcast "votes_#{user_id}_channel",
      message: 'votes_updated',
      talk_id: talk_id,
      html: html
  end
end
