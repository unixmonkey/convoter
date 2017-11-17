class ConferencesController < ApplicationController
  before_action :require_admin, except: [:show, :set_day]
  before_action :set_conference, only: [:show, :edit, :update, :destroy, :set_day]

  # GET /conferences
  # GET /conferences.json
  def index
    @conferences = Conference.all
  end

  # GET /conferences/1
  # GET /conferences/1.json
  def show
    session[:current_conference_id] = params[:id]
    @day_index = session["conference_#{params[:id]}_current_day"]
  end

  # GET /conferences/new
  def new
    @conference = Conference.new
  end

  # GET /conferences/1/edit
  def edit
    @conference.slots.build unless @conference.slots.present?
  end

  # POST /conferences
  # POST /conferences.json
  def create
    @conference = Conference.new(conference_params)

    respond_to do |format|
      if @conference.save
        format.html { redirect_to @conference, notice: 'Conference was successfully created.' }
        format.json { render :show, status: :created, location: @conference }
      else
        format.html { render :new }
        format.json { render json: @conference.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /conferences/1
  # PATCH/PUT /conferences/1.json
  def update
    respond_to do |format|
      if @conference.update(conference_params)
        format.html { redirect_to @conference, notice: 'Conference was successfully updated.' }
        format.json { render :show, status: :ok, location: @conference }
      else
        format.html { render :edit }
        format.json { render json: @conference.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /conferences/1
  # DELETE /conferences/1.json
  def destroy
    @conference.destroy
    respond_to do |format|
      format.html { redirect_to conferences_url, notice: 'Conference was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def set_day
    session["conference_#{params[:id]}_current_day"] = params[:day]
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_conference
      @conference = Conference.includes(slots: [:talks]).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def conference_params
      params.require(:conference).permit(:description, :name, :year, :starts_at, :ends_at)
    end
end
