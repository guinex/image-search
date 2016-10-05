class SubappsController < ApplicationController
  before_action :set_subapp, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  # GET /subapps
  # GET /subapps.json
  def index
    @user = current_user
    @subapps = Subapp.all
  end

  # GET /subapps/1
  # GET /subapps/1.json
  def show 
  end

  # GET /subapps/new
  def new
    @subapp = Subapp.new
  end

  # GET /subapps/1/edit
  def edit
  end

  # POST /subapps
  # POST /subapps.json
  def create
    @subapp = Subapp.new(subapp_params)
    respond_to do |format|
      if @subapp.save
        format.html { redirect_to @subapp, notice: 'Subapp was successfully created.' }
        format.json { render :show, status: :created, location: @subapp }
      else
        format.html { render :new }
        format.json { render json: @subapp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subapps/1
  # PATCH/PUT /subapps/1.json
  def update
    respond_to do |format|
      if @subapp.update(subapp_params)
        format.html { redirect_to @subapp, notice: 'Subapp was successfully updated.' }
        format.json { render :show, status: :ok, location: @subapp }
      else
        format.html { render :edit }
        format.json { render json: @subapp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subapps/1
  # DELETE /subapps/1.json
  def destroy
    @subapp.destroy
    respond_to do |format|
      format.html { redirect_to subapps_url, notice: 'Subapp was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subapp
      @subapp = Subapp.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subapp_params
      params.fetch(:subapp, {}).permit(:appname, :description)
    end
end
