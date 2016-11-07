class HomeController < ApplicationController
  def show
    @conferences = Conference.upcoming
  end
end
