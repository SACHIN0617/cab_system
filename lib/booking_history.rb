require "json"
require 'date'
require_relative './car.rb'
require "byebug"

class BookingHistory

    attr_accessor :booking_history
    attr_reader :per_min_cost, :per_km_cost, :pink_car_cost

    def initialize
        file_data = JSON.load File.open "/Users/Sachin/workspace/taxi-app/sample_data/booking_history.json"
        @booking_history = file_data["booking_history"]
        @per_min_cost = 1
        @per_km_cost = 2
        @pink_car_cost = 5
    end

    def find_history(id)
        booking_history.find { |e| e["id"] == id }
    end

    def create(car_id, user_id, lattitude, longitude)
        booking = {
            "id": booking_history.length > 0 ? booking_history[booking_history.length - 1]["id"].to_i + 1 : 1,
            "car_id": car_id,
            "user_id": user_id,
            "started_at": nil,
            "ended_at": nil,
            "is_cancelled": false,
            "amount": nil,
            "start_location_lattitude": lattitude,
            "start_location_longitude": longitude,
            "end_location_lattitude": nil,
            "end_location_longitude": nil
        }
        booking_history.push(booking)
        update_json
        puts "Car is booked and Booking id is #{booking[:id]}"
        booking
    end

    def update_start_time(id)
        if !find_history(id)
            puts "No booking found"
            return
        end
        booking_history.each do |ele|
            if (ele["id"] == id)
                ele["started_at"] = DateTime.now
                break
            end
        end
        update_json

        puts "Ride for booking details #{id} is succesfully started"
    end

    def update_end_ride(car_id, id, end_location)
        car = Car.new.find(car_id)
        amount = calculate_amount(id, end_location, car["car_type"])
        booking_history.each do |ele|
            if (ele["id"] == id)
                ele["ended_at"] = DateTime.now
                ele["amount"] = amount.to_i
                ele["end_location_lattitude"] = end_location[:lattitude]
                ele["end_location_longitude"] = end_location[:longitude]
                break
            end
        end
        update_json
        return find_history(id)
    end

    def cancel_ride(id)
        booking_history.each do |ele|
            if (ele["id"] == id)
                ele["is_cancelled"] = true
                break
            end
        end
        update_json
        return find_history(id)
    end

    private

    def update_json
        File.open('/Users/Sachin/workspace/taxi-app/sample_data/booking_history.json',"w") {|f| f.write({ "booking_history": booking_history}.to_json)}
    end

    def calculate_distance(user_location, end_location)
        x = (user_location[:lattitude].to_f - end_location[:lattitude].to_f) ** 2
        y = (user_location[:longitude].to_f - end_location[:longitude].to_f) ** 2
        Math.sqrt(x + y)
    end

    def calculate_time(start_time) 
        time_difference = DateTime.now - DateTime.parse(start_time)
        (time_difference * 24 * 60).to_i
    end

    def calculate_amount(id, end_location, type)
        history = find_history(id)
        start_location = {"lattitude": history["start_location_lattitude"], "longitude": history["start_location_longitude"]}
        distance = calculate_distance(start_location, end_location)
        time = calculate_time(history["started_at"])
        amount = distance * per_km_cost + time * per_min_cost
        type == "Pink" ? amount + pink_car_cost : amount
    end
end
