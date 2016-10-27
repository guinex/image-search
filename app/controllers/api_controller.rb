class ApiController < ApplicationController
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
end
