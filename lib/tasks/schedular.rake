#3
desc "This task is called by the Heroku schedular to create similar images"
task :process_similar_images => :environment do
  current_cluster = SystemConstant.get('CURRENT_IMAGE_PROCESSING_BATCH').to_i
  ColorCluster.where('id > ?', current_cluster).find_in_batches(batch_size: 5).each do |batch|
    puts batch.size
    batch.each do |cluster|
      puts cluster.id
      ColorCluster.where('id <> ?', cluster.id ).where(category_id: cluster.category_id).find_each(batch_size: 500) do |all_cluster|
        puts "---------#{all_cluster.id}"
        if (relation = HelperMethod.calculate_relation(all_cluster.color_scaled, cluster.color_scaled, 100))
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
          puts '_____________________success_____________________'
        elsif (relation = HelperMethod.calculate_relation(all_cluster.gray_scaled, cluster.gray_scaled, 100))
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
          puts '____________________success_______________________'
        else
          next
          puts '_______________relation failure_____________________'
        end
      end
      current_cluster +=1
      SystemConstant.where(name: 'CURRENT_IMAGE_PROCESSING_BATCH').update_all(value: current_cluster)
    end
  end
end

#2
desc "This task is called by the Heroku schedular to create similar images"
task :add_to_cluster => :environment do
  ImageSearch.where('cluster_id is null').find_each(batch_size: 100) do |imagesearch|
    imagesearch.add_to_cluster
  end
end
#1
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
#INFI
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

#NA
desc "This fetches designs from manage catalog and perform either creation of new cluster"
task :fetch_new_design_data => :environment do
  design_ids = ManageCatalog.where(proccessing_state: PROCESS_NEW_EVENT).pluck(:design_ids)
  
  if design_ids.present?
    connection = ReadonlyConnection.connect
    results = []
    design_ids.each_slice(500) do |ids|
      query = "SELECT id, design_id, kind from images where design_id in (#{ids.join(',')}) and kind = 'master'"
      results.push *connection.execute(query)
    end
    connection.disconnect!
    ReadonlyConnection.reset_connection
    # results.each do |result|
    #   if result['designable_type'].present?
    #     category = Category.where(name: result['designable_type']).first_or_create
    #     ImageSearch.where(design_id: result['id']).first.update_column(:category_id, category.id)
    #   end
    # end
  end
end

  # ColorCluster.where('id in (?)', [450113,408595]).find_in_batches(batch_size: 5).each do |batch|
  #   batch.each do |cluster|408595
  #     puts cluster.id
      cluster = ColorCluster.find 408595
      ColorCluster.where('id = ?', 450113 ).where(category_id: cluster.category_id).find_each(batch_size: 500) do |all_cluster|
        puts "---------#{all_cluster.id}"
        puts all_cluster.color_scaled
        puts cluster.color_scaled
        if (relation = HelperMethod.calculate_relation(all_cluster.color_scaled, cluster.color_scaled, 1000))
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
          puts '_____________________color success_____________________'
        elsif (relation = HelperMethod.calculate_relation(all_cluster.gray_scaled, cluster.gray_scaled, 100))
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
          puts '____________________gray success_______________________'
        else
          next
          puts '_______________relation failure_____________________'
        end
      end
  #   end
  # end