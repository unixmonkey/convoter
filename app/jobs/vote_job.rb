class VoteJob < ApplicationJob
  queue_as :default

  def perform(user_id, talk_id)
    vote = Vote.find_by(user_id: user_id, talk_id: talk_id)
    slot = vote.talk.slot
    html = ConferencesController.render slot,
      locals: { current_user: vote.user }
    ActionCable.server.broadcast "votes_#{user_id}_channel",
      message: 'votes_updated',
      slot_id: slot.id,
      talk_id: talk_id,
      html: html
  end
end
