# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create!(name:  "Daniel Brett",
             email: "dbrett14@gmail.com",
             password:              "Hello#123!",
             password_confirmation: "Hello#123!",
             admin: true,
             subscribed: true, 
             activated: true,
             activated_at: Time.zone.now)



# 99.times do |n|
#   name  = Faker::Name.name
#   email = "example-#{n+1}@railstutorial.org"
#   password = "password"
#   User.create!(name:  name,
#                email: email,
#                password:              password,
#                password_confirmation: password)
# end

User.create!(name:  "Daniel Brett",
             email: "dbrett15@gmail.com",
             password:              "Hello#123!",
             password_confirmation: "Hello#123!",
             admin: false, 
             activated: true,
             activated_at: Time.zone.now)