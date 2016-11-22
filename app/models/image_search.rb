class ImageSearch < ApplicationRecord
  require 'phashion'
  require 'net/http'
  #require 'rubygems'   
  require 'open-uri'

  #serialize :design_ids, Array
  serialize :similar_designs, Array
  serialize :color_histogram, Hash
  validates :design_id, uniqueness: true
  METHODS_ATTR =[:fingerprint, :exact, :similar]
  
  METHODS_ATTR.each do |attribute|
    method_name = "#{attribute}_of_design".to_sym
    self.send :define_singleton_method, method_name do |* args|
      self.send(attribute,*args)
    end
  end

  def self.similar(fingerprint)
    ImageSearch.where(fingerprint: fingerprint).pluck(:similar_designs)
  end

  def self.exact(fingerprint)
    ImageSearch.where(fingerprint: fingerprint).pluck(:design_id)
  end

  def self.fingerprint(id)
    ImageSearch.where(design_id: id).pluck(:fingerprint)
  end

  def self.process_images
    file_path = '/tmp/image_upload_data.csv'
    images = SmarterCSV.process(file_path)
    make_fingerprint(images) if images.present?
  end

  def self.remove_similar(design_id,id)
    fingerprint = fingerprint_of_design(design_id)

    similar_designs = similar_of_design(fingerprint_of_design(design_id))
    similar_designs.flatten!
    similar_designs.delete(* id)
    ImageSearch.where(fingerprint: fingerprint).update_all(similar_designs: similar_designs)
  end

  def self.add_similar(design_id,id)
    images = ImageSearch.where(fingerprint:fingerprint_of_design(design_id))
    similar_design_array = exact_of_design(fingerprint_of_design(id))
    similar_design_array.flatten!
    similar_designs = images.pluck(:similar_designs)
    similar_designs.flatten!
    similar_designs.push(* similar_design_array)
    images.update_all(similar_designs: similar_designs)
  end

  def self.find_similar_in_group(design_id)
    fingerprint = fingerprint_of_design(design_id)
    get_all_similar(fingerprint)
  end  

  def self.search_image(design_ids)
    result = exact_of_design(fingerprint_of_design(design_ids))
    similar_designs = similar_of_design(fingerprint_of_design(design_ids))
    result = result.compact
    similar_result = similar_designs.flatten.compact
    similar_designs_url = similar_result.nil? ? {} : ImageSearch.get_thumbnail(similar_result)
    design_url = result.nil? ? {} : ImageSearch.get_thumbnail(result)
    return design_url, similar_designs_url
  end

  ##################################################
  # RUN AFTER: EQUAL IMAGE                         #
  # should run after equal images task runs for    #
  # desired images else could overlap with equal   #
  # image task                                     #
  # do not increase the limit                      #                                              
  ##################################################

  def self.automated_update_similar_designs(images)
    image_ids = images.collect(&:id)
    color_histogram = images.collect(&:color_histogram)
    design_ids = images.collect(&:design_id)
    check_similar_images(color_histogram,image_ids,design_ids)    
  end

  private

  def self.make_fingerprint(images)
    images_to_insert = []
    failed_batch = []

    images.each_with_index do |img,index|
      begin
        if (file_path = check_if_url_exists(img[:id], img[:photo_file_name])).present?
          thumb_path = check_if_url_exists(img[:id], img[:photo_file_name], true)
          image_search =ImageSearch.new
          phashion_obj = Phashion::Image.new(file_path)
          image_search.phash_obj = Marshal.dump(phashion_obj)
          image_search.fingerprint = phashion_obj.fingerprint
          image_search.design_id = img[:design_id]
          image_search.image_id = img[:id]
          image_search.color_histogram = get_color_histogram(thumb_path,file_path)
          images_to_insert.push(image_search)
          puts index
        else
          next
        end
      rescue
        failed_batch << ([]<< img[:id])
        next
      end
    end
    FailedImage.import ['image_id'], failed_batch, validate:false
    return unless images_to_insert.present?
    insert_and_update_images(images_to_insert) 
  end

  def self.get_color_histogram(path,full_path)
    img =  Magick::Image.read(full_path).first
    total = 0
    color_graph = { :r => 0.0, :g => 0.0, :b => 0.0}
    img.quantize.color_histogram.each { |c, n|
      color_graph[:r] += n * c.red
      color_graph[:g] += n * c.green
      color_graph[:b] += n * c.blue
      total   += n}
    color_hash = {}
    colors = Miro::DominantColors.new(path)
    max_color_percent= colors.by_percentage
    colors.to_hex.each_with_index do |hex_code, index|
      color_hash[hex_code] = max_color_percent[index]
    end
    color_histogram_hash={total: total,color_graph: color_graph, avg: color_graph.values.inject(:+)/total, color_hash: color_hash} 
    puts color_hash
    color_histogram_hash
  end

  ###############################################
  # Search for similar designs in pre-processed #
  # data.                                       #
  ###############################################

  def self.check_similar_images(color_histograms,image_ids,design_ids)
    image_ids.each_with_index do |id,index|
      similar_images =[]
      image_ids.each_with_index do |in_id,in_index|
        unless (index == in_index)
          color_histogram = color_histograms[index]
          c_color_histogram = color_histograms[in_index]
          if (color_histogram[:avg] - c_color_histogram[:avg]).abs < 300 &&
            (color_histogram[:color_hash].keys - c_color_histogram[:color_hash].keys).length < 6 
              similar_images.push(* design_ids[in_index])
          end  
        end
      end
      if similar_images.present?
        image_search = ImageSearch.where(id: id).first
        equal_images = exact_of_design(fingerprint_of_design(image_search.fingerprint))
        equal_images.delete_if{|eq| eq == image_search.design_id}
        similar_designs =image_search.similar_designs
        similar_designs.push(* similar_images)
        similar_designs = similar_designs - equal_images
        similar_designs.uniq!
        image_search.update_column(:similar_designs,similar_designs)
      end
    end
  end

  ###################################################
  # insert records using active record import       #
  # no callbacks or validation check them before    #
  # hand.                                           #
  ###################################################

  def self.insert_and_update_images(images_to_insert)
    ImageSearch.import images_to_insert,validate:true
  end

  ##################################################
  # check if the given url exists                  #
  # response is 200 if url is correct              #
  # creates a path where image can be found as full#
  # path                                           #
  # response not equal 200 will not be processed   #
  ##################################################

  def self.check_if_url_exists(id, file,thumb = nil)
    return "" unless file.present?
    file_name = file
    last_separator_at = file.rindex(/[.]/)
    extension = (last_separator_at.present?) ? file_name[last_separator_at..file_name.length] : '.'
    last_separator_at = file.length + 1  if extension == '.'
    full_path = 'http://s3-ap-southeast-1.amazonaws.com/mirraw/images/'+"#{id}"+"/"+"#{file_name[0..(last_separator_at-1)]}"
    unless thumb.present?
      file_path = full_path +'_small'+"#{extension}"+'?34'
    else
      file_path = full_path +'_thumb'+"#{extension}"+'?35'
    end
    url = URI.parse(file_path)
    uri = URI(url)
    request = Net::HTTP.new uri.host
    response= request.request_head uri.path
    unless (response.code == "200")
      return ""
    end
    file_path
  end
  
  
  ###############################################
  # Create a readonly connection and fetch image# 
  # Returns array of hash containing.           #
  # image id, design id, image photo file name  #
  ###############################################

  def self.get_master_images_for_image_search
    image_array = []
    current_batch = SystemConstant.where(name: 'CURRENT_IMAGE_PROCESSING_BATCH').first
    query = "SELECT id, design_id, photo_file_name FROM images WHERE kind = 'master' and photo_file_name is not null and design_id is not null and id > #{current_batch.value} ORDER BY id LIMIT 10000"
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

  def self.get_thumbnail(design_ids)
    image_array = {}
    if design_ids.present?
      image_search = ImageSearch.where(design_id: design_ids)
      image_search.each do |image|
        phashion_object = Marshal::load(image.phash_obj)
        path = phashion_object.filename.split('_')
        ext_path = path.last.gsub(/original.|zoom. |small./,'thumb.')
        path.delete(path.last)
        path.push(* ext_path)
        path = path.join('_')
        image_array["#{image.design_id}"] = path
      end
    end
    image_array
  end

  def self.get_all_similar(fingerprint)
    image_search = ImageSearch.where(fingerprint: fingerprint)
    similar_design_array = []
    image_search.each_with_index do |image,index|
      img_phash_obj = Marshal::load(image.phash_obj)
      image.similar_designs.each_with_index do |design_id,in_index|
        in_image = ImageSearch.where(design_id: design_id).first        
        in_img_phash_obj = Marshal::load(in_image.phash_obj)
        unless (img_phash_obj).duplicate?(in_img_phash_obj, :threshold => 12)
          image.similar_designs.delete(design_id)
        else  
          similar_design_array.push(* design_id)
        end  
      end
    end
    image_search.update_all(similar_designs: similar_design_array)
  end
end