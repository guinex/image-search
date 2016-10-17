class ImageSearch < ApplicationRecord
  require 'phashion'
  require 'net/http'
  #require 'rubygems'   
  require 'open-uri'
  serialize :design_ids, Array
  serialize :similar_designs, Array
  #tested
  def self.process_images
    file_path = '/tmp/image_upload_data.csv'
    images = SmarterCSV.process(file_path)
    make_fingerprint(images) if images.present?
  end
  #tested
  def self.search_image(design_ids)
    result = "606"
    if (images = get_image_for_design_from_readonly(design_ids)) 
      images.each do |image|
        if (file_path = check_if_url_exists(image[:id], image[:photo_file_name])).present?
          fingerprint = (Phashion::Image.new(file_path)).fingerprint
          result = ImageSearch.where(fingerprint: fingerprint)
        end
      end
    end  
    result
  end
  #tested
  def self.automated_upload_new_images
    images = self.get_master_images_for_image_search
    make_fingerprint(images) if images.present?
  end 
  ##################################################
  # RUN BEFORE: SIMILAR IMAGE                      #
  # should run similar images task runs for        #
  # desired images else could overlap with similar #
  # image task                                     #  
  ##################################################
  #tested
  def self.re_arrange_equal_images
    images = ImageSearch.where('processed_for_equal_at is null or processed_for_equal_at >= ?',1.weeks.from_now).order("RANDOM()").limit(1000)
    if images.present? 
      image_id_processed = []
      images.each do |image|
        unless image_id_processed.include?(image.id)
          equal_images = ImageSearch.where(fingerprint: image.fingerprint)
          equal_image_hash = equal_images.as_json
          equal_image_hash.delete_if{|img| img['id']==image.id}
          equal_image_ids = equal_images.as_json.map{|x| x['id']}
          if equal_image_hash.present? && equal_image_hash.count > 1
            image_id_processed << image.id
            equal_image_hash.each do |img|
              img.design_ids.each do |design_id|
                image.design_ids << design_id unless image.design_ids.include? design_ids
              end  
            end
            image.design_ids = image.design_ids.flatten
            ImageSearch.delete(equal_image_ids)
            image.save!
          end
        end  
      end
      images.update_all(processed_for_equal_at: Time.zone.now())
    end  
  end

  ##################################################
  # RUN AFTER: EQUAL IMAGE                         #
  # should run after equal images task runs for    #
  # desired images else could overlap with equal   #
  # image task                                     #
  # do not increase the limit                      #                                              
  ##################################################

  def self.automated_update_similar_designs
    images = ImageSearch.where('processed_for_similar_at is null or processed_for_similar_at >= ?',1.weeks.from_now).order("RANDOM()").limit(1000)
    if images.present?
      design_ids = images.collect(&:design_ids)
      design_ids.each_with_index do |id,index|
        design_ids[index] = id[0]
      end
      image_ids = images.collect(&:id)
      id_design_ids =  image_ids + design_ids
      image_feed = get_image_for_design_from_readonly(design_ids.join(','))
      check_similar_images(image_feed,id_design_ids)    
    images.update_all(processed_for_similar_at: Time.zone.now())
    end
  end

  private
  #tested
  def self.make_fingerprint(images)
    images_to_insert = []
    images.each do |img|
      if (file_path = check_if_url_exists(img[:id], img[:photo_file_name])).present?
        image_hash ={}
        image_hash[:fingerprint] = (Phashion::Image.new(file_path)).fingerprint
        image_hash[:id] = img[:design_id]
        images_to_insert.push(image_hash)
      else
        next
      end
    end
    return unless images_to_insert.present?
    images_to_insert = check_equals(images_to_insert)
    insert_and_update_images(images_to_insert) 
  end
  #tested
  def self.check_equals(values)
    processed_fingerprint=[]
    processed_ids=[]
    values.each_with_index do |x,i|
      if processed_fingerprint.include?(x[:fingerprint])
        (processed_ids[processed_fingerprint.index(x[:fingerprint])] ||= []) << x[:id]
      else 
        processed_fingerprint << x[:fingerprint]
        (processed_ids[i] ||= []) << x[:id]
      end
    end
    processed_ids = processed_ids.compact
    processed_data = []
    processed_fingerprint.each_with_index do |fingerprint, index|
      processed_data[index] = []
      processed_data[index] << fingerprint
      processed_data[index]<< processed_ids[index]
    end
    return processed_data
  end

  ###############################################
  # Search for similar designs in pre-processed #
  # data.                                       #
  # Intakes readonly data and pre-processed     #
  # data                                        #
  # readonly: image id, design id, photofilename#
  # pre-processed: id, design_ids               #
  ###############################################

  def self.check_similar_images(images,id_design_ids)
    similar_images = []
    file_path = []
    images.each_with_index do |img,index|  
      path = {}
      path['id'] = img[:design_id]
      path['url'] = check_if_url_exists(img[:id], img[:photo_file_name])
      file_path << path
    end
    if file_path.present?
      file_path.each_with_index do |path,index|
        design_id = [[path['id']]]
        file_path.each_with_index do |in_path,in_index|
          unless in_index == index
            if (Phashion::Image.new(path['url']).duplicate?(Phashion::Image.new(in_path['url']), :threshold => 0))
              design_id[1] << in_path['id']
            elsif (Phashion::Image.new(path['url']).duplicate?(Phashion::Image.new(in_path['url']), :threshold => 2))
              design_id[1] << in_path['id']
            elsif (Phashion::Image.new(path['url']).duplicate?(Phashion::Image.new(in_path['url']), :threshold => 12))
              design_id[1] << in_path['id']
            end    
          end
        end  
        similar_images << design_id   
      end
    end
    self.merge_similar_images(similar_images,id_design_ids)
  end

  ######################################################
  # will merge similar design with others so as to     #
  # improve search results.                            #
  # Does not reduced enteries                          #
  ######################################################

  def self.merge_similar_images(similar_images,id_design_ids)
    similar_images.each do |similar|
      if similar[1].present?
        if id_design_ids[1].include? similar[0]
          image_id = id_design_ids[0][id_design_ids[1].index(similar[0])]
          if (image = ImageSearch.where(id: image_id).first).present?
            design_present = image.similar_designs if image.similar_designs.present?
            design_present = (design_present.present?) ?  (design_present + similar[1]) : similar[1]
            image.update_column(:similar_designs, design_present)
          end
        end  
      end
    end
  end

  ###################################################
  # insert records using active record import       #
  # no callbacks or validation check them before    #
  # hand.                                           #
  ###################################################
  #tested
  def self.insert_and_update_images(images_to_insert)
    format_to_insert = ['fingerprint','design_ids']
    ImageSearch.import format_to_insert, images_to_insert
  end

  ##################################################
  # check if the given url exists                  #
  # response is 200 if url is correct              #
  # creates a path where image can be found as full#
  # path                                           #
  # response not equal 200 will not be processed   #
  ##################################################
  #tested
  def self.check_if_url_exists(id, file)
    return "" unless file.present?
    file_name = file
    last_separator_at = file.rindex(/[.]/)
    file_path = 'https://assets0.mirraw.com/images/'+"#{id}"+"/"+"#{file_name[0..(last_separator_at-1)]}"+'_zoom'+"#{file_name[last_separator_at..file_name.length]}"+'?3424323'
    url = URI.parse(file_path)
    uri = URI(url)
    request = Net::HTTP.new uri.host
    response= request.request_head uri.path
    unless (response.code == "200")
      return ""
    end
    file_path
  end
  
  ##################################################
  # crawl to each image and check if it is similar #
  # take live enteries as input                    #
  ##################################################
  #tested
  def self.get_image_for_design_from_readonly(design_ids)
    image_array = []
    if design_ids.present?
      query = "SELECT id, design_id, photo_file_name FROM images WHERE design_id in ("+"#{design_ids}"+") and kind = 'master' and photo_file_name is not null"
      connection = ReadonlyConnection.connect
      results = connection.execute(query)
      connection.disconnect!
      ReadonlyConnection.reset_connection
      results.each do |image|
        temp ={}
        temp[:id] = image['id']
        temp[:photo_file_name] = image['photo_file_name']
        temp[:design_id] = image['design_id']
        image_array << temp
      end
    end
    image_array
  end
  
  ########################################################
  # check if design_id are present in pre-processed data #
  # may give in-accurate results                         #
  # does not hit url                                     # 
  ########################################################
  
  def self.get_image_for_design(design_ids)
    result = []
    d_id = design_ids.split(',')
    ImageSearch.each do |img|
      if img.design_ids.include?(d_id)
        result << img.design_ids 
      end 
    end
    results
  end

  # def get_best_seller(sell_at, category)   
  #   category =  Category.find_by_namei(params[:category])
  #   d_order_states = "'pickedup', 'pending', 'dispatched', 'completed'"
  #   get_category_query = "SELECT * "
  #   li_created_between = Time.zone.now.beginning_of_day().advance(days: - params[:sell_at].to_i)..Time.zone.now.end_of_day()
  #   designs = category.designs.joins( line_items: :designer_order).select("designs.id, sum(line_items.quantity) as sell_count").where(line_items: {designer_order: {state: d_order_states}, created_at: li_created_between}).group('designs.id').order('sum(line_items.quantity) DESC')
  #   design_ids = designs.collect(&:id)
  # end
  #tested
  def self.get_master_images_for_image_search
    image_array = []
    current_batch = SystemConstant.where(name: 'CURRENT_IMAGE_PROCESSING_BATCH').first
    query = "SELECT id, design_id, photo_file_name FROM images WHERE kind = 'master' and photo_file_name is not null and design_id is not null and id > #{current_batch.value} ORDER BY id LIMIT 1000"
    connection = ReadonlyConnection.connect
    results = connection.execute(query)
    connection.disconnect!
    ReadonlyConnection.reset_connection
    results.each do |image|
      temp ={}
      temp[:id] = image['id']
      temp[:photo_file_name] = image['photo_file_name']
      temp[:design_id] = image['design_id']
      image_array << temp
    end
    current_batch.update_column(:value, results.values.last[0])
    image_array
  end
end
