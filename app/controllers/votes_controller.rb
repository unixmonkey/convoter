class VotesController < ApplicationController
  def create
    talk = Talk.find(params[:talk_id])
    talk.slot.votes.where(user_id: current_user.id).destroy_all
    current_user.votes.create(talk_id: params[:talk_id])
    redirect_to conference_path(talk.slot.conference)
  end

  def destroy
    vote = current_user.votes.find_by(id: params[:id])
    vote&.destroy
    redirect_to conference_path(vote&.talk&.slot&.conference)
  end
end
