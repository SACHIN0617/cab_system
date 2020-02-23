require "json"
require 'date'
require_relative './car.rb'

class User 
    attr_accessor :users
    def initialize
        file_data = JSON.load File.open "/Users/Sachin/workspace/taxi-app/sample_data/users.json"
        @users = file_data["users"]
       
    end

    def find_by(id)
        users.find { |e| e["id"] == id }
    end

    def self.find(id)
        new.find_by(id)
    end

    def self.book_ride(user_id, lattitude, longitude, type = nil) 
        user = find_by(user_id)
        if user
            Car.new.book_cab(user_id, lattitude, longitude, type)
        else
            puts "User not found"
        end
    end

    def self.start_ride(user_id, booking_id)
        user = find_by(user_id)
        if user
            Car.new.start_ride(booking_id)
        else
            puts "User not found"
        end
    end

    def self.end_ride(user_id, booking_id, lattitude, longitude)
        user = find_by(user_id)
        if user
            Car.new.end_ride(booking_id, lattitude, longitude)
        else
            puts "User not found"
        end
    end

    def self.cancel_ride(user_id, booking_id)
        user = find_by(user_id)
        if user
            Car.new.cancel_ride(booking_id)
            puts "Ride with booking id #{booking_id} is cancelled successful"
        else
            puts "User not found"
        end
    end
end
