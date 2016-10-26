class ApiController < ApplicationController
  def get_similar_designs
    images = ImageSearch.where('design_id in (?)',params[:id]).pluck(:fingerprint)
    designs = ImageSearch.where(fingerprint: fingerprint).pluck(:design_id)
    designs = designs.delete_if{|id| params[:id].split(',').include?(id)}
    return designs
  end
end
