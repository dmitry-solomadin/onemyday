# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Rapns::Apns::App.create({name: "onemyday_development",
                         certificate: File.read("./config/certs/apn_development.pem"),
                         environment: "development",
                         password: "",
                         connections: 1
                        })

=begin
Rapns::Apns::App.create({name: "onemyday_production",
                         certificate: File.read("/config/certs/apn_production.pem"),
                         environment: "production",
                         password: "",
                         connections: 1
                        })
=end
