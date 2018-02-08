desc "This task is called by the Heroku schedular to create similar images"
task :process_similar_images => :environment do
  current_cluster = SystemConstant.get('CURRENT_IMAGE_PROCESSING_BATCH').to_i
  ColorCluster.where('id > ?', current_cluster).find_in_batches(batch_size: 5).each do |batch|
    puts batch.size
    batch.each do |cluster|
      puts cluster.id
      ColorCluster.where('id <> ?', cluster.id ).find_each(batch_size: 50000) do |all_cluster|
        puts "---------#{all_cluster.id}"
        if (relation = HelperMethod.calculate_relation(all_cluster.color_scaled, cluster.color_scaled))
          distance= nil
          if relation.is_a?(Integer)
            distance = relation
            relation = :least_alike
          end
          if distance.present?
            ColorCluster.generate_cluster_relation(cluster, all_cluster, relation, distance)
          else
            ColorCluster.generate_cluster_relation(cluster, all_cluster, relation)
          end
          puts '________________success___________________'
        elsif (relation = HelperMethod.calculate_relation(all_cluster.gray_scaled, cluster.gray_scaled))
          distance= nil
          if relation.is_a?(Integer)
            distance = relation
            relation = :least_alike
          end
          if distance.present?
            ColorCluster.generate_cluster_relation(cluster, all_cluster, relation, distance)
          else
            ColorCluster.generate_cluster_relation(cluster, all_cluster, relation)
          end
          puts '________________success___________________'
        else
          next
          puts '_______________could not find_____________________'
        end
      end
      current_cluster +=1
      SystemConstant.where(name: 'CURRENT_IMAGE_PROCESSING_BATCH').update_all(value: current_cluster)
    end
  end
end


desc "This task is called by the Heroku schedular to create similar images"
task :add_to_cluster => :environment do
  ImageSearch.where('cluster_id is null').find_each(batch_size: 100) do |imagesearch|
    imagesearch.add_to_cluster
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
      current_design_ids = {}
      results.group_by{|h| h['designable_type']}.each{|k,v| v.select{|j| (current_design_ids[k] ||=[]) << j['id']}}
      current_design_ids.each do |key, value|
        if value.present?
          category = Category.where(name: key).first_or_create
          ImageSearch.where(design_id: value).update_all(category_id: category.id)
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


