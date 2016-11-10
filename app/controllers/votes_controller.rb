class VotesController < ApplicationController
  def create
    talk = Talk.find(params[:talk_id])
    talk.slot.votes.where(user_id: current_user.id).destroy_all
    current_user.votes.create(talk_id: params[:talk_id])
    head :ok
  end

  def destroy
    current_user.votes.where(talk_id: params[:talk_id]).destroy_all
    head :ok
  end
end
