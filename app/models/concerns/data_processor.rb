module DataProcessor
  class Processor

    def fetch_data
      ImageSearch.where.not(cluster_id: nil).find_in_batches(batch_size: 2000) do |image_batch|
        self.class.process_and_get_data(image_batch.collect(&:design_id), nil, 'N', 'N')
      end
    end

    def process_and_get_data(designs, file_name, within ='N', replace = 'N')
      counter =0
      if within == 'N' && replace == 'Y'
        #####################################replace algo needed###################################################
        # File.open("tmp/replaced_designs_all","w") do |f|
        #   data = []
        #   ImageSearch.where.not(cluster_id: nil).where(design_id: design_ids).find_each(batch_size: 500) do |img|
        #     hash = {}
        #     hash[image.design_id] => image.get_cluster_data
        #     data << hash

        #   end
        #   f.write(data.join("\n").gsub('=>',':'))
        # end
      elsif replace == 'Y' && within == 'Y'
        design_ids = designs.keys
        results = []
        all_designs = Set.new
        ImageSearch.get_cluster_data(design_ids).each do |cluster_id, design_id_array|
          design_id_array.map{|d| all_designs << d}
          design_hash = designs.select{|k,v| design_id_array.include? k}
          results << design_hash.sort_by{|k,v| v}.first if design_hash
        end
        CSV.open("tmp/#{file_name}_replaced.csv", "w", {col_sep: ","}) do |csv|
          csv << ['design_id', 'position']
          results.each do |data|
            csv << data
          end
          (designs.keys - all_designs.to_a).each do |design_id|
            csv << [design_id, designs[design_id]]
          end
        end
      elsif within == 'N' && replace == 'N'
        File.open("tmp/similar_designs_data.json","w") do |f|
          data = []
          ImageSearch.where.not(cluster_id: nil,design_id: designs).find_each(batch_size: 500) do |img|
            hash = {}
            hash[img.design_id] =img.get_cluster_data
            data << hash
          end
          f.write(data.join("\n").gsub('=>',':'))
        end
      end
    end
  end

  class FileDataMapper
    def find_similar_in_csv(file_name, parameters)
      processor = Processor.new
      file_path = '/tmp/raw_file.csv'
      bestsellers = SmarterCSV.process(file_path)
      design_ids_bestsellers ={}
      bestsellers.collect{|btslr| design_ids_bestsellers[btslr[:design_id].to_i] = btslr[:position].to_i}
      if parameters[:find_within].present? || parameters[:replace_within].present?
        processor.process_and_get_data(design_ids_bestsellers, file_name, parameters[:find_within], parameters[:replace_within])
      end
      # design_id
      # header
      # CSV.open("tmp/#{file_name}_bestseller.csv", "w", {col_sep: ","}) do |f|
      #   f << %w(design_id average_rating discount_price sell_count margin designer_rating total_reviews average_rating_by_user link ) unless header
      #   header = true
      #   btslr_design = []
      #   btslr_design_customer = []
      #   query = "select designs.id, designs.average_rating, discount_price, sell_count,
      #   (discount_price*transaction_rate)/100 as margin, 
      #   designers.average_rating as designer_rating 
      #   from designs, designers 
      #   where designs.designer_id = designers.id 
      #   and designs.id in (#{design_ids_bestsellers.join(',')}) 
      #   group by 1,2,3,4,6, designers.transaction_rate"
      #   connection = ReadonlyConnection.connect
      #   results = connection.execute(query)
      #   results.each{|r| btslr_design << r}

      #   query = "select design_id, count(id), avg(rating) 
      #   from  reviews where reviews.design_id in (#{design_ids_bestsellers.join(',')})
      #   and reviews.order_id is not null
      #   group by design_id"
      #   results = connection.execute(query)
      #   results.each{|r| btslr_design_customer << r}

      #   #in similar
      #   btslr_design_customer = btslr_design_customer.delete_if{|r| design_ids_bestsellers.exclude?(r['design_id'].to_i)}
      #   #############
      #   design_ids_bestsellers.each do |id|
      #     row = []
      #     btslr_design.select{|r| r['id'] == id.to_i}.first.each{|k,v| row << v}
      #     if (rating = btslr_design_customer.select{|r| r['design_id'] == id.to_i}.first).present?
      #       rating.each{|k,v| row << v if(k != 'design_id')}
      #     else
      #       row << ''
      #       row << ''
      #     end
      #     row << "=HYPERLINK(\"http://www.mirraw.com/d/#{id}\")"
      #     f << row
      #   end
      #   connection.disconnect!
      #   ReadonlyConnection.reset_connection
      # end
      # header = false
      # CSV.open("tmp/#{file_name}.csv", "w", {col_sep: ","}) do |f|
      #   f << %w(btslr_design_id design_id average_rating discount_price sell_count margin designer_rating total_reviews average_rating_by_user link ) unless header
      #   header = true
      #   bestsellers.each do |btslr|
      #     if (design = ImageSearch.where(design_id: btslr[:design_id]).first).present?
      #       result_set = []
      #       result_set_customer_rating = []
      #       design_id = design.design_id
      #       similar_designs = ImageSearch.where(cluster_id: design.cluster_id).where('design_id <> ?', design_id).pluck(:design_id)
      #       if similar_designs.present?
      #         query = "select designs.id, designs.average_rating, discount_price, sell_count, 
      #         (discount_price*transaction_rate)/100 as margin, designers.average_rating as designer_rating 
      #         from designs, designers 
      #         where designs.designer_id = designers.id and designs.id in (#{similar_designs.join(',')}) 
      #         group by 1,2,3,4,6, designers.transaction_rate"
      #         connection = ReadonlyConnection.connect
      #         results = connection.execute(query)           
      #         results.each{|r| result_set << r}

      #         query = "select design_id, count(id), avg(rating) 
      #         from  reviews 
      #         where reviews.design_id in (#{similar_designs.join(',')}) and reviews.order_id is not null
      #         group by design_id"
      #         results = connection.execute(query)
      #         results.each{|r| result_set_customer_rating << r}
      #         connection.disconnect!
      #         ReadonlyConnection.reset_connection
      #       end
      #       similar_designs.each do |id|
      #         row = [design_id]
      #         result_set.select{|r| r['id'] == id.to_i}.first.each{|k,v| row << v}
      #         if (rating = result_set_customer_rating.select{|r| r['design_id'] == id.to_i}.first).present?
      #           rating.each{|k,v| row << v if(k != 'design_id')}
      #         else
      #           row << ''
      #           row << ''
      #         end
      #         row << "=HYPERLINK(\"http://www.mirraw.com/d/#{id}\")"
      #         f << row
      #       end
      #     else
      #       next
      #     end
      #   end
      # end
    end
  end
end