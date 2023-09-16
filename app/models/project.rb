class Project < ApplicationRecord
  belongs_to :tenant
  validates_uniqueness_of :title
  has_many :artifacts, dependent: :destroy
  has_many :user_projects
  has_many :users, through: :user_projects
  validate :free_plan

  def free_plan
    if self.new_record? && (tenant.projects.count > 0) && (tenant.plan == 'free')
      errors.add(:base, "Free plans cannot have more than one project.")
    end
  end

  def self.by_user_plan_and_tenant(tenant_id, user)
    tenant = Tenant.find(tenant_id)

    if tenant.plan == 'premium'
      user.is_admin? ? tenant.projects : user.projects.where(tenant_id: tenant.id)
    else
      user.is_admin? ? tenant.projects.order(:id).limit(1) : user.projects.where(tenant_id: tenant.id)
    end
  end

end
