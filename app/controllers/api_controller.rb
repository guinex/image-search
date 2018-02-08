class ApiController < ApplicationController
  skip_before_filter :authenticate_user!

  def get_similar_designs
    response_hash = {}
    ImageSearch.where('design_id in (?)',params[:id].split(',')).each do |img|
      response_hash[img.design_id] = img.get_cluster_data(img.design_id) - [img.design_id]
    end
    if params[:search].present? && params[:search] == 'exact'
      response_hash
    else
      response_hash
      # response = {id: designs.pluck(:design_id).flatten.uniq.join(','), similar_designs: designs.pluck(:similar_designs).flatten.uniq.join(',')}
    end
    render :json => response_hash
  end

  def international_catalog_designs
    design_ids = ManageCatalog.where(processing_state: 'waiting', geo: 'international').pluck(:design_id)
    render :json => {id: design_ids}
  end

  def international_catalog_response
    design_ids = params[:design_ids]
    ManageCatalog.where(design_id: design_ids, geo: 'international').update_all(processing_state: 'complete')
    ManageCatalog.where(geo: 'international', processing_state: 'waiting').update_all(processing_state: 'failed')
    render :json => {status: 'ok'}
  end

end
