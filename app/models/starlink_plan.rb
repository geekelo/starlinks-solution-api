class StarlinkPlan < ApplicationRecord
   has_many :starlink_kits, optional: true
end
