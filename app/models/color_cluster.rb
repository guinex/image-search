class ColorCluster < ApplicationRecord
  has_many :image_search
  has_many :cluster_relation
  serialize :color_hash_percent, Hash
  serialize :gray_scaled, Array
  serialize :color_scaled, Array

  def self.assign_cluster(image_search_id)
    imagesearch = ImageSearch.find_by_id(image_search_id)
    cluster = ColorCluster.create(gray_scaled: imagesearch.color_histogram[:tiles_matrix_gray_scaled], color_scaled: imagesearch.color_histogram[:tiles_matrix_colored], color_hash_percent: imagesearch.color_histogram[:color_hash], category_id: imagesearch.category_id)
    imagesearch.update_column(:cluster_id,cluster.id)
  end

  private

  # ##########################################################################
  # generate new measures from cluster to this design all the next distance  #
  # will be calculated from this cluster                                     #
  ############################################################################

  def self.generate_cluster_relation(cluster, related_cluster, type, distance=0)
    grade = ColorCluster.compare_color_percent(cluster.color_hash_percent, related_cluster.color_hash_percent)
    ClusterRelation.generate(cluster.id, related_cluster.id, type, grade, distance)
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

end
