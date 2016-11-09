class VotesController < ApplicationController
  def create
    current_user.votes.where(talk_id: params[:talk_id]).first_or_create
    # ActionCable.server.broadcast "votes_#{params[:talk_id]}_channel",
    #                              message: 'votes_updated'
    head :ok
  end

  def destroy
    current_user.votes.where(talk_id: params[:talk_id]).destroy_all
    # ActionCable.server.broadcast "votes_#{params[:talk_id]}_channel",
    #                              message: 'votes_updated'
    head :ok
  end
end
