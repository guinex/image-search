class ColorCluster < ApplicationRecord
  has_many :image_search
  has_many :cluster_relation
  serialize :color_hash_percent, Hash
  after_create :build_cluster_relation
  CLUSTER_TYPES_AND_PINS =[:dimension, :vector, :adjacent, :new, :pin]
  PIN_LINK_THRESHOLD = 90
  CLUSTER_TYPES_AND_PINS.each do |attribute|
    method_name = ["create_#{attribute}_cluster".to_sym,"#{attribute}_cluster".to_sym] 
    method_name.each do |method|
      self.send :define_singleton_method, method do |* args|
        args << {type: attribute.to_s}
        self.send('cluster',*args)
      end
    end
  end

  def self.assign_cluster(id)
    if (image_search = ImageSearch.find_by_id(id)).present?
      argument_hash = {cluster: {average: image_search.color_histogram[:avg],color_graph: image_search.color_histogram[:color_graph], color_hash: image_search.color_histogram[:color_hash], key_hash: image_search.color_histogram[:color_hash].keys.join('').hash}, design_id: image_search.design_id, category_id: image_search.category_id}
      create_cluster(argument_hash)

    end
  end

  def find_distance(array1, array2)
    distance =[]
    array1.each_with_index do |arr1, index|
      array2.each do |arr2|
        color1_arry = ColorCluster.split_in_hex(arr1)
        color2_arry = ColorCluster.split_in_hex(arr2)
        coordinates = {}
        color1_arry.each_with_index do |rgb, i|
          coordinates[:x] = (rgb.hex - color2_arry[i].hex)**2 if i == 0
          coordinates[:y] = (rgb.hex - color2_arry[i].hex)**2 if i == 1
          coordinates[:z] = (rgb.hex - color2_arry[i].hex)**2 if i == 2
        end
        distance << Math.sqrt(coordinates.values.inject(:+))
      end
    end
    distance
  end

  def self.split_in_hex(color)
    color.gsub('#','').split('').each_slice(2).map(&:join)
  end

  def create_cluster(args)
    new_cluster = ColorCluster.create(average: args[:cluster][:average], color_hash_percent: args[:cluster][:color_hash], key_hash: args[:cluster][:key_hash], category_id: args[:category_id])
    return new_cluster.id
  end

  def self.cluster(* args)
    case args.last[:type]
    when 'new'
      if (args = args.first).present?
        new_cluster = ColorCluster.create(average: args.first[:cluster][:average], color_hash_percent: args.first[:cluster][:color_hash], key_hash: args.first[:cluster][:key_hash], category_id: args.first[:category_id])
        return new_cluster.id
      end
    when 'pin'
      if args.first[:cluster].present?
        ColorCluster.add_pin_to_cluster(args)
      end
    when 'dimension'
      if args.first[:cluster_average].present? && args.first[:category_1] ==  args.first[:category_2]
        if (args.first[:cluster_average][:average1] - args.first[:cluster_average][:average2]).abs <= 500
          if (args.first[:color_hash_percent][:color_hash1].keys & args.first[:color_hash_percent][:color_hash2].keys).length > 5
            color_grade = compare_color_percent(args.first[:color_hash_percent][:color_hash1],args.first[:color_hash_percent][:color_hash2])
            return (100 + color_grade)
          end
        end
      end
      return 0
    when 'vector'
      if args.first[:cluster_average].present? && args.first[:color_hash_percent].present? && args.first[:category_1] !=  args.first[:category_2]
        if (args.first[:cluster_average][:average1] - args.first[:cluster_average][:average2]).abs <= 500
          if (args.first[:color_hash_percent][:color_hash1].keys & args.first[:color_hash_percent][:color_hash2].keys).length > 5
            color_grade = compare_color_percent(args.first[:color_hash_percent][:color_hash1],args.first[:color_hash_percent][:color_hash2])
            return (200 + color_grade)
          end
        end
      end
      return 0
    when 'adjacent'
      if args.first[:cluster_average].present? && args.first[:color_hash_percent].present?
        if (args.first[:color_hash_percent][:color_hash1].keys & args.first[:color_hash_percent][:color_hash2].keys).length > 6
          color_grade = compare_color_percent(args.first[:color_hash_percent][:color_hash1],args.first[:color_hash_percent][:color_hash2])
          return (100 + color_grade)
        end
      end
      return 0
    else
      puts "something went wrong!!!"
    end
  end

  def build_cluster_relation
    if (clusters = ColorCluster.where('(average between ? and ?) or (key_hash = ?)',self.average.to_i-750, self.average.to_i+750, self.key_hash)).present?
      if (clusters = clusters.reject{|cls| cls.id == self.id}).present?
        cluster_array = clusters.collect{|c| [c.id,c.average]}
        cluster_array.map!{|i| [i[0],(i[1].to_f - self.average.to_f).abs]}
        closest_id = cluster_array.sort_by!{|closest_cluster| closest_cluster[1]}.first[0]
        nearest_cluster = ColorCluster.where(id: closest_id).first #change this cluster already loaded
        ColorCluster.generate_cluster_relation(self,nearest_cluster)
      end
    end
  end
  private

  # ##########################################################################
  # generate new measures from cluster to this design all the next distance  #
  # will be calculated from this cluster                                     #
  ############################################################################
  def self.add_pin_to_cluster(args)
    clusters = ColorCluster.where('(average between ? and ?) and (category_id = ?)',args.first[:cluster][:average].to_i-10000, args.first[:cluster][:average].to_i+10000,args.first[:category_id]).to_a
    if clusters.present?
      cluster_array = clusters.collect{|c| [c.id,c.average]}
      cluster_array.map!{|i| [i[0],(i[1].to_f - args.first[:cluster][:average].to_f).abs]}
      closest = cluster_array.sort_by{|closest_cluster| closest_cluster[1]}.first[0]
      nearest_cluster = ColorCluster.where(id: closest).first #change this cluster already loaded
      g_score = compare_color_percent(args.first[:cluster][:color_hash], nearest_cluster.color_hash_percent)
      if g_score < PIN_LINK_THRESHOLD
        create_new_cluster(args)
      else
        nearest_cluster.id
      end
    else
      create_new_cluster(args)
    end 
  end

  def self.generate_cluster_relation(cluster, connected_cluster)
    cluster_args ={cluster_average: {average1: cluster.average, average2: connected_cluster.average},
    color_hash_percent: {color_hash1: cluster.color_hash_percent, color_hash2: connected_cluster.color_hash_percent}, category_1: connected_cluster.category_id, category_2: cluster.category_id}
    relation = Hash.new
    relation[:dimension] = ColorCluster.dimension_cluster(cluster_args)
    relation[:vector] = ColorCluster.vector_cluster(cluster_args)
    relation[:adjacent] = ColorCluster.adjacent_cluster(cluster_args)
    relation_type = relation.max_by{|k,v| v}.first.to_s
    if (grade = relation.values.inject(:+)) > 0
      z_distance = get_zdistance(cluster.average, connected_cluster.average, grade).round(2)
      ClusterRelation.generate(cluster.id, connected_cluster.id, relation_type, grade, z_distance)
    end
  end

  def self.compare_color_percent(color_hash1,color_hash2)
    grade = [0]
    (color_hash1.keys & color_hash2.keys).each do |hex|
      if (color_hash1[hex] - color_hash2[hex]).abs * 100 < 10
        grade << 10
      elsif (color_hash1[hex] - color_hash2[hex]).abs * 100 < 20
        grade << 9
      elsif (color_hash1[hex] - color_hash2[hex]).abs * 100 < 30
        grade << 8
      elsif (color_hash1[hex] - color_hash2[hex]).abs * 100 < 40
        grade << 7
      elsif (color_hash1[hex] - color_hash2[hex]).abs * 100 < 50
        grade << 6
      elsif (color_hash1[hex] - color_hash2[hex]).abs * 100 < 60
        grade << 5
      elsif (color_hash1[hex] - color_hash2[hex]).abs * 100 < 70
        grade << 4
      elsif (color_hash1[hex] - color_hash2[hex]).abs * 100 < 80
        grade << 3
      elsif (color_hash1[hex] - color_hash2[hex]).abs * 100 < 90
        grade << 2
      else (color_hash1[hex] - color_hash2[hex]).abs * 100 < 100
        grade << 1
      end  
    end
    grade.inject(:+)
  end

  def self.get_zdistance(avg1, avg2, grade)
    (avg1.to_f - avg2.to_f).abs/ grade.to_f
  end
end
