require "json"
require 'date'
require_relative './booking_history.rb'
require "byebug"

class Car

    attr_accessor :cars, :booking_history

    def initialize
        car_file_data = JSON.load File.open "/Users/Sachin/workspace/taxi-app/sample_data/cars.json"
        @cars = car_file_data["cars"]
        @booking_history = BookingHistory.new
    end

    def find(id)
        cars.find { |e| e["id"] == id }
    end
    
    def book_cab(user_id, lattitude, longitude, type = nil)
        available_cars = find_available_cars(lattitude, longitude, type);
        if available_cars.length == 0
            puts "No cars available now, please try after some time."
            return
        end
        update_car_booking_status(available_cars[0]["id"], true)
        booking_history.create(available_cars[0]["id"], user_id, lattitude, longitude);
    end

    def start_ride(booking_id)
        booking_history.update_start_time(booking_id)
    end

    def end_ride(booking_id, lattitude, longitude)
        end_location = {"lattitude": lattitude, "longitude": longitude}
        booking = booking_history.find_history(booking_id)
        if !booking
            puts "No booking found"
            return
        end
        booking = booking_history.update_end_ride(booking["car_id"], booking_id, end_location)
        update_car_details_on_end_trip(booking["car_id"], end_location)
        puts "Ride ended the amount to be paid #{booking['amount']}"
    end

    def cancel_ride(booking_id)
        history = booking_history.cancel_ride(booking_id)
        update_car_booking_status(history["car_id"], false)
        history
    end

    private

    def update_car_booking_status(id, flag)
        cars.each do |ele|
            if (ele["id"] == id)
                ele["is_booked"] = flag
                break
            end
        end
        update_json
    end

    def update_car_details_on_end_trip(id, end_location)
        cars.each do |ele|
            if (ele["id"] == id)
                ele["is_booked"] = false,
                ele["lattitude"] = end_location[:lattitude],
                ele["longitude"] = end_location[:longitude]
                break
            end
        end
        update_json
    end

    def find_available_cars(lattitude, longitude, type)
        car_type = type ? type : "Normal"
        for i in 1..3 do
            result = cars.select do |elem|
                elem["lattitude"] <= lattitude + i &&
                elem["lattitude"] >= lattitude - i && 
                elem["longitude"] <= longitude + i &&
                elem["longitude"] >= longitude - i &&
                elem["car_type"] == car_type &&
                !elem["is_booked"]
            end
            if result.length > 0
                return result
            end
        end
        if result.length == 0 
            return []
        end
    end

    def update_json
        File.open('/Users/Sachin/workspace/taxi-app/sample_data/cars.json',"w") {|f| f.write({ "cars": cars}.to_json)}
    end
end

