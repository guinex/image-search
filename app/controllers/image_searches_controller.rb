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
    if request.post?
      if (params[:csv_file]).present?
        file = params[:csv_file].read.force_encoding("ASCII-8BIT").encode('UTF-8', undef: :replace, replace: '')
        filename = 'image_upload_data.csv'
        File.open(File.join('/tmp/', filename), 'w+') { |f| f.write file }
        ImageSearch.process_images
        send_file('/tmp/failed_image_data.csv')
      elsif params[:design_id].present?
        @url,@similar_url = ImageSearch.search_image(params[:design_id])
        # unless response == "606"
        #   render json: {result: response}
        # else
        #   render json: {alert: "No Designs Found"}
        # end
      elsif params[:upload_images].present?
        ImageSearch.automated_upload_new_images
      end
    end
  end

  def remove_similar_design
    ImageSearch.remove_similar(params[:id],params[:design_id])
  end

  def add_similar_design
    ImageSearch.add_similar(params[:id],params[:design_id])
  end

  def re_check_similar
    ImageSearch.find_similar_in_group(params[:id])
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
