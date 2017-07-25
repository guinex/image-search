class ManageCatalogsController < ApplicationController
  before_action :set_manage_catalog, only: [:show, :edit, :update, :destroy]

  # GET /manage_catalogs
  # GET /manage_catalogs.json
  def index
    @manage_catalogs = ManageCatalog.all
  end

  # GET /manage_catalogs/1
  # GET /manage_catalogs/1.json
  def show
  end

  # GET /manage_catalogs/new
  def new
    @manage_catalog = ManageCatalog.new
  end

  # GET /manage_catalogs/1/edit
  def edit
  end

  # POST /manage_catalogs
  # POST /manage_catalogs.json
  def create
    @manage_catalog = ManageCatalog.new(manage_catalog_params)

    respond_to do |format|
      if @manage_catalog.save
        format.html { redirect_to @manage_catalog, notice: 'Manage catalog was successfully created.' }
        format.json { render :show, status: :created, location: @manage_catalog }
      else
        format.html { render :new }
        format.json { render json: @manage_catalog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /manage_catalogs/1
  # PATCH/PUT /manage_catalogs/1.json
  def update
    respond_to do |format|
      if @manage_catalog.update(manage_catalog_params)
        format.html { redirect_to @manage_catalog, notice: 'Manage catalog was successfully updated.' }
        format.json { render :show, status: :ok, location: @manage_catalog }
      else
        format.html { render :edit }
        format.json { render json: @manage_catalog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /manage_catalogs/1
  # DELETE /manage_catalogs/1.json
  def destroy
    @manage_catalog.destroy
    respond_to do |format|
      format.html { redirect_to manage_catalogs_url, notice: 'Manage catalog was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def remove_designs_from_catalog
    @restricted_access = true
    @remove_catalog_int = true
    @remove_catalog_domestic = false
    if request.xhr?
      if params[:design_id].present?
        if params[:geo] == 'international'
          ManageCatalog.where(design_id: params[:design_id].to_s, geo:'international').first_or_create.update_column(:processing_state,'waiting')
        elsif params[:geo] == 'domestic'
          ManageCatalog.where(design_id: params[:design_id].to_s, geo:'domestic').first_or_create.update_column(:processing_state,'waiting')
        end
        render json: {status: 'ok'}
      else 
        render json: {status: 'invalid'}
      end
    elsif request.post? && params[:id].present?
      @url,@related_url = ImageSearch.search_image(params[:id])
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_manage_catalog
      @manage_catalog = ManageCatalog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def manage_catalog_params
      params.fetch(:manage_catalog, {})
    end
end
