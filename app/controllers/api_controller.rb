class ApiController < ApplicationController
  skip_before_filter :authenticate_user!

  def get_similar_designs
    response_hash = {}
    ImageSearch.where('design_id in (?)',params[:id].split(',')).each do |img|
      response_hash[img.design_id] = img.get_cluster_data
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
    design_ids = ManageCatalog.where(processing_state: 'remove_international').pluck(:design_id)
    render :json => {id: design_ids}
  end

  def international_catalog_response
    design_ids = params[:design_ids]
    ManageCatalog.where(design_id: design_ids).update_all(processing_state: 'complete')
    ManageCatalog.where(processing_state: 'remove_international').update_all(processing_state: 'failed')
    render :json => {status: 'ok'}
  end

  def update_data_queue
    cluster_data = params[:event_data]
    cluster_data.each do |event, design_ids|
      design_ids.each do |design_id|
        ManageCatalog.where(design_id: design_id, processing_state: event.to_s).first_or_create
      end
    end
  end

  def send_queued_data

  end
end
