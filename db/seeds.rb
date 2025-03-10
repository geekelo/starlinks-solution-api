# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

StarlinkPlan.find_or_create_by!(name: "Enterprise Plan") do |plan|
  plan.id = SecureRandom.uuid
  plan.price = 120_000.00
  plan.status = "default"
end

puts "✅ Starlink Enterprise Plan seeded successfully!"

StarlinkPlan.find_or_create_by!(name: "89k Plan") do |plan|
  plan.id = SecureRandom.uuid
  plan.price = 89_000.00
  plan.status = "deprecated"
end

puts "✅ Starlink 89k Plan seeded successfully!"

StarlinkPlan.find_or_create_by!(name: "600k Plan") do |plan|
  plan.id = SecureRandom.uuid
  plan.price = 600_000.00
  plan.status = "optional"
end

puts "✅ Starlink 600k Plan seeded successfully!"

StarlinkPlan.find_or_create_by!(name: "210k Plan") do |plan|
  plan.id = SecureRandom.uuid
  plan.price = 210_000.00
  plan.status = "optional"
end

puts "✅ Starlink 210k Plan seeded successfully!"


# Create an admin user
StarlinkUser.find_or_create_by!(email: 'starlinkisolutions@gmail.com') do |user|
  user.password = 'securepassword'  # Replace with a strong password
  user.password_confirmation = 'securepassword'
  user.role = 'admin'
  user.name = 'Starlink Installation Solutions'
end

# Find the admin user
admin = StarlinkUser.find_by(email: 'starlinkisolutions@gmail.com')

# Create wallet if it doesn't exist
if admin
  StarlinkUserWallet.find_or_create_by!(starlink_user_id: admin.id) do |wallet|
    wallet.balance = 0.0  # Starting balance
    wallet.wallet_id = 'byaste'  # Adjust currency if needed
  end
else
  puts "Admin user not found. Please create the admin user first."
end

puts "✅ Starlink User seeded successfully!"
