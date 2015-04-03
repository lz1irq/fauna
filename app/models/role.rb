class Role < ActiveRecord::Base
  PREDEFINED_ROLES = [:board_member].freeze

  has_and_belongs_to_many :users, join_table: :users_roles
  belongs_to :resource, polymorphic: true

  validates :resource_type,
            inclusion: {in: Rolify.resource_types},
            allow_nil: true

  validates :name, inclusion: {in: Role::PREDEFINED_ROLES.map(&:to_s)}

  scopify
end