class VotesChannel < ApplicationCable::Channel
  def subscribed
    stream_from("votes_channel")
  end

  def unsubscribed
  end

  def send_message(data)
    talk = Talk.find_by(id: data['talk_id'])
    if talk && current_user
      talk.votes.create(user_id: current_user.id)
    end
  end
end
