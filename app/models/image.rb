class Image < ApplicationRecord
  require 'phashion'
  require 'net/http'
  require 'rubygems'
  require 'nokogiri'   
  require 'open-uri'

  serialize :design_ids, Array

  def self.process_images
    file_path = '/tmp/image_upload_data.csv'
    images = SmarterCSV.process(file_path)
    make_fingerprint(images) if images.present?
  end

  def self.search_image(id)
    page = Nokogiri::HTML(RestClient.get("http://www.mirraw.com"+"d/#{id}"))
    #images = Image.where(fingerprint: fingerprint)
  end

  private
      # links do
      #   explore xpath: '//*[@class="wrapper"]/div[1]/div[1]/div[2]/ul/li[1]/a' do |e|
      #     e.gsub(/Explore/, "Love")
      #   end  
      #   features css: '.features'
      #   enterprise css: '.enterprise'
      #   blog css: '.blog'
      # end



  #def self.check(file,category=nil)
  #  search = Phashion::Image.new(file)
  #  images = (category.present?) ? category_wise_process_image(category) :  
  #  images.each do |img|
  #    #if search.duplicate?(Phashion::Image.new('https://assets3.mirraw.com/images/'+"#{img[:id]}"+"/"+"#{img[:link]}"))
  #    if search.duplicate?(Phashion::Image.new("#{img[:link]}"))
  #      img_ids << img[:id]
  #    end
  #  end
  #  designs = Design.where(id: Image.where(id: img_ids))
  #end

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

  def self.check_equals(values)
    processed_fingerprint=[]
    processed_ids=[]
    values.each_with_index do |x,i|
      if processed_fingerprint.include?(x[:fingerprint])
        processed_ids[processed_fingerprint.index(x[:fingerprint])] << x[:id]
      else 
        processed_fingerprint << x[:fingerprint]
        processed_ids[i] = []
        processed_ids[i] << x[:id]
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

  #def self.category_wise_process_image(category = "sarees")
  #  if (c = Category.find_by_name(category)).present?
  #   images = c.designs.joins(:images).where('images.fingerprint_processed = ?', true).where('kind = ?','master').select('images.id')
  #  end
  #end

  def self.insert_and_update_images(images_to_insert)
    format_to_insert = ['fingerprint','design_ids']
    Image.import format_to_insert, images_to_insert
  end

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
end
