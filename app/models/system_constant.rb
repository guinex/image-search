class SystemConstant < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true
  validates_presence_of :value

  def self.get(name)
    where(:name => name).pluck(:value).first
  end
end
