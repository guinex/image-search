class ImageSearchesController < ApplicationController
  before_action :set_image_search, only: [:show, :edit, :update, :destroy]

  # GET /image_searches
  # GET /image_searches.json
  def index
    @image_searches = ImageSearch.all
  end

  # GET /image_searches/1
  # GET /image_searches/1.json
  def show
  end

  # GET /image_searches/new
  def new
    @image_search = ImageSearch.new
  end

  # GET /image_searches/1/edit
  def edit
  end

  # POST /image_searches
  # POST /image_searches.json
  def create
    @image_search = ImageSearch.new(image_search_params)

    respond_to do |format|
      if @image_search.save
        format.html { redirect_to @image_search, notice: 'Image search was successfully created.' }
        format.json { render :show, status: :created, location: @image_search }
      else
        format.html { render :new }
        format.json { render json: @image_search.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /image_searches/1
  # PATCH/PUT /image_searches/1.json
  def update
    respond_to do |format|
      if @image_search.update(image_search_params)
        format.html { redirect_to @image_search, notice: 'Image search was successfully updated.' }
        format.json { render :show, status: :ok, location: @image_search }
      else
        format.html { render :edit }
        format.json { render json: @image_search.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /image_searches/1
  # DELETE /image_searches/1.json
  def destroy
    @image_search.destroy
    respond_to do |format|
      format.html { redirect_to image_searches_url, notice: 'Image search was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search_and_upload_image
    if (params[:csv_file]).present?
      file = params[:csv_file].read
      filename = 'image_upload_data.csv'
      File.open(File.join('/tmp/', filename), 'wb') { |f| f.write file }
      ImageSearch.process_images
    elsif params[:design_id].present?
      response = ImageSearch.search_image(params[:design_id])
      unless response == "606"
        render json: {result: response}
      else
        render json: {alert: "No Designs Found"}  
      end
    elsif params[:upload_images].present?
      ImageSearch.automated_upload_new_images
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_image_search
      @image_search = ImageSearch.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_search_params
      params.fetch(:image_search, {}).permit(:all)
    end
end
