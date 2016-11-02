class ApiController < ApplicationController
  skip_before_filter :authenticate_user!

  def get_similar_designs
    fingerprint = ImageSearch.where('design_id in (?)',params[:id]).pluck(:fingerprint)
    designs = ImageSearch.select('design_id,similar_designs').where(fingerprint: fingerprint)
    if params[:search].present? && params[:search] == 'exact'
      response = {id: designs.pluck(:design_id).flatten.uniq.join(',')}
    else
      response = {id: designs.pluck(:design_id).flatten.uniq.join(','), similar_designs: designs.pluck(:similar_designs).flatten.uniq.join(',')}
    end
    render :json => response
  end

  def international_catalog_designs
    design_ids = ManageCatalog.where(processing_state: 'waiting', geo: 'international').pluck(:design_id)
    render :json => {id: design_ids}
  end
end
