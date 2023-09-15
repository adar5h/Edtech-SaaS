class Tenant < ApplicationRecord

   acts_as_universal_and_determines_tenant
   has_many :members, dependent: :destroy
   has_many :projects, dependent: :destroy
   validates_uniqueness_of :name
   validates_presence_of :name
   has_one :payment
   accepts_nested_attributes_for :payment
   # when a tenant is going to sign up, its going to be handled through the registrations/new form and in that form not only are we going to hit the tenant table but also the payments table
  # So the user accepts the nested attributes for payment through form submission.

  # We have User/Tenant and Payment, where a user makes a payment.
  # With this setup, if you want to create a user along with payment for that user in a single form submission, you can do something like this in your controller and view.
  # When the user form is submitted, the attributes for both the tenant and the associated payment are sent to the controller.
  # The accepts_nested_attributes_for declaration in this model allows the nested attributes for payment to be processed and associated with the tenant.

   def can_create_projects?
    (plan == 'free' && projects.count < 1 ) || (plan == 'premium')
   end

    def self.create_new_tenant(tenant_params, user_params, coupon_params)

      tenant = Tenant.new(tenant_params)

      if new_signups_not_permitted?(coupon_params)

        raise ::Milia::Control::MaxTenantExceeded, "Sorry, new accounts not permitted at this time"

      else
        tenant.save    # create the tenant
      end
      return tenant
    end

  # ------------------------------------------------------------------------
  # new_signups_not_permitted? -- returns true if no further signups allowed
  # args: params from user input; might contain a special 'coupon' code
  #       used to determine whether or not to allow another signup
  # ------------------------------------------------------------------------
  def self.new_signups_not_permitted?(params)
    return false
  end

  # ------------------------------------------------------------------------
  # tenant_signup -- setup a new tenant in the system
  # CALLBACK from devise RegistrationsController (milia override)
  # AFTER user creation and current_tenant established
  # args:
  #   user  -- new user  obj
  #   tenant -- new tenant obj
  #   other  -- any other parameter string from initial request
  # ------------------------------------------------------------------------
    def self.tenant_signup(user, tenant, other = nil)
      #  StartupJob.queue_startup( tenant, user, other )
      # any special seeding required for a new organizational tenant
      #
      Member.create_org_admin(user)
      #
    end


end
