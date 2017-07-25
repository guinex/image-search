class ClusterRelation < ApplicationRecord
  belongs_to :color_cluster
  # before_save :initialise

  def self.generate(id, connected_cluster_id, type, grade, distance)
    ids = [id, connected_cluster_id].sort.reverse!
    unless ClusterRelation.where(cluster_id: ids[0],  related_id: ids[1]).exists?
      ClusterRelation.create(cluster_id: ids[0],  related_id: ids[1], relation_type: type, grade: grade, z_distance: distance)
    end
  end

  # def self.get_similar_clusters(cluster_id, only= nil)
  #   cluster = ClusterRelation.where(cluster_id: cluster_id).first
  #   {parent: cluster.self_and_ancestors, child: cluster.self_and_descendants, sibling: cluster.self_and_siblings}
  # end

  private

  # def initialise
  #   parent_id=0
  # end
end
