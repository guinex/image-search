class ClusterRelation < ApplicationRecord
  belongs_to :color_cluster
  def self.generate(id, connected_cluster_id, type, grade, distance)
    ClusterRelation.create(cluster_id: id, related_id: connected_cluster_id, relation_type: type, grade: grade, z_distance: distance)
  end

  def self.get_similar_clusters(cluster_id, only= nil)
    unless only.present?
      ClusterRelation.where(related_id: cluster_id).order('grade desc').pluck(:cluster_id)
    else
      ClusterRelation.where(related_id: cluster_id, relation_type: only).order('grade desc').pluck(:cluster_id)
    end
  end
end
