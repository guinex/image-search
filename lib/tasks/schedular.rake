desc "This task is called by the Heroku schedular to create similar images"
task :process_similar_images => :environment do
  images = ImageSearch.select('id, design_id, color_histogram').where('similar_designs is null')
  if images.present?
    images.update_all(processed_for_similar_at: Time.zone.now())
    ImageSearch.automated_update_similar_designs(images)
  end
end

desc "This task is called by the Heroku schedular to create clusters and pins"
task :create_clusters => :environment do
  ids = ImageSearch.where('design_id is not null and cluster_id is null').limit(10000).pluck(:id)
  if ids.present?
    ImageSearch.add_to_cluster_by_task(ids)
  end
end

desc "This task takes design ids and find its category"
task :update_categories => :environment do
  ImageSearch.where("category_id is null").find_in_batches(batch_size: 10000) do |imgs|
    ids = imgs.collect{|img| [img.id, img.design_id]}.to_h
    design_ids = ids.values
    ids = ids.keys
    if ids.present?
      connection = ReadonlyConnection.connect
      query = "SELECT designable_type, id from designs where id in (#{design_ids.join(',')})"
      results = connection.execute(query)
      connection.disconnect!
      ReadonlyConnection.reset_connection
      results.each do |result|
        if result['designable_type'].present?
          category = Category.where(name: result['designable_type']).first_or_create
          ImageSearch.where(design_id: result['id']).first.update_column(:category_id, category.id)
        end
      end
    end
  end
end

desc "This task checks if image still exists"
task :delete_where_image_changed => :environment do
  ImageSearch.all.find_in_batches(batch_size: 10000) do |imgs|
    ids = imgs.collect{|img| [img.id, Marshal::load(img.phash_obj)]}.to_h
    design_ids = ids.values
    ids = ids.keys
    if ids.present?
      connection = ReadonlyConnection.connect
      query = "SELECT designable_type, id from designs where id in (#{design_ids.join(',')})"
      results = connection.execute(query)
      connection.disconnect!
      ReadonlyConnection.reset_connection
      results.each do |result|
        if result['designable_type'].present?
          category = Category.where(name: result['designable_type']).first_or_create
          ImageSearch.where(design_id: result['id']).first.update_column(:category_id, category.id)
        end
      end
    end
  end
end
# 100.times do
#   images = ImageSearch.select('id, design_id, color_histogram').where('design_id is not null').order('random()').limit(100000)
#   if images.present?
#     images.update_all(processed_for_similar_at: Time.zone.now())
#     ImageSearch.automated_update_similar_designs(images)
#   end
# end


desc "This task upload_file_on_s3"
task :upload_file_on_s3 => :environment do
  # designs = []
  # ImageSearch.where.not(similar_designs: nil).find_in_batches(batch_size: 10000) do |imgs|
  #   hash = {}
  #   imgs.each do |i|
  #     similar_designs = []
  #     i.similar_designs.each{|id| similar_designs << id.to_i}
  #     hash[i.design_id] = similar_designs.to_a.join(',')
  #     designs << hash
  #   end
  # end
  # File.open("tmp/similar_designs.json","w") do |f|
  #   f.write(designs.to_json)
  # end
  #   connection = Fog::Storage.new({
  #     :provider                 => 'AWS',
  #     :aws_access_key_id        => "AKIAIKTPLVJVYHE7XGYA",
  #     :aws_secret_access_key    => "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",
  #     :region => "ap-southeast-1"
  #   })

  #   # First, a place to contain the glorious details
  #   directory = connection.directories.new(
  #     :key    => "mirraw-test"
  #   )

  #   directory.files.create(
  #     :key    => "ImageSearch/similar_designs.csv",
  #     :body   => file,
  #     :public => true
  #   )
end