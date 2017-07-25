desc "This task is called by the Heroku schedular to create similar images"
task :process_similar_images => :environment do
  current_cluster = SystemConstant.get('CURRENT_IMAGE_PROCESSING_BATCH')
  ColorCluster.where('id > ?', current_cluster).find_in_batches(batch_size: 10).each do |batch|
    batch.each do |cluster|
      ColorCluster.find_each(batch_size: 500) do |all_cluster|
        if (relation = HelperMethod.calculate_relation(all_cluster.color_scaled, cluster.color_scaled) || HelperMethod.calculate_relation(all_cluster.gray_scaled, cluster.gray_scaled))
          ColorCluster.generate_cluster_relation(cluster, all_cluster, relation)
        else
          next
        end
      end
    end
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


