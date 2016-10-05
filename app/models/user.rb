class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  after_save :assign_default_role
  attr_accessor :login
  private
  def assign_default_role
    self.add_role(:user) if self.roles.blank?
  end
end
