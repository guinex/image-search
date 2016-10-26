desc "This task is called by the Heroku schedular to create new fingerprints"
task :process_images => :environment do
  images = ImageSearch.get_master_images_for_image_search
  ImageSearch.delay(queue: 'high_priority', priority: -10).make_fingerprint(images) if images.present?
end

desc "This task is called by the Heroku schedular to create similar images"
task :process_similar_images => :environment do
  images = ImageSearch.select('id, design_id, color_histogram').where('design_id is not null').where('id > ?',25324).order("RANDOM()").limit(1000)
  if images.present?
    images.update_all(processed_for_similar_at: Time.zone.now())
    ImageSearch.automated_update_similar_designs(images)
  end  
end