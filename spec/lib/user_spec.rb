require_relative '../../lib/user.rb'
require_relative '../../lib/car.rb'
require_relative '../../lib/booking_history.rb'
require "json"
require 'date'

describe "Cab Booking" do
    let!(:booking) { User.book_ride(1, 5, 3, type = nil) }   

    describe 'Book Ride' do
        context "book the cab" do
            it "should book the cab" do
                car = Car.new.find(booking["car_id"])
                booking_history = BookingHistory.new.find(booking["id"])

                expect(car["is_booked"]).to eq(true)

                expect(booking_history["started_at"]).to be_nil

                expect(booking_history["user_id"]).to eq(1)

                expect(booking_history["car_id"]).to eq(booking["car_id"])
                
                expect(booking_history["is_cancelled"]).to eq(false)
            end
        end
    end

    describe 'Start Ride' do
        context "Once the ride is started" do
            it "updates the start time in booking history table" do
                User.start_ride(1, booking["id"])
                car = Car.new.find(booking["car_id"])
                booking_history = BookingHistory.new.find(booking["id"])

                expect(car["is_booked"]).to eq(true)

                expect(booking_history["started_at"]).not_to be_nil

                expect(booking_history["user_id"]).to eq(1)

                expect(booking_history["car_id"]).to eq(booking["car_id"])

                expect(booking_history["is_cancelled"]).to eq(false)
            end
        end
    end

    describe 'End Ride' do
        context "Once the ride is ended " do

            before(:all) do
                car = Car.new.find(booking["car_id"])
                User.end_ride(1, booking["id"], 10, 20)
            end

            it "updates the car booking status" do
                car = Car.new.find(booking["car_id"])
                expect(car["is_booked"]).to eq(false)

                expect(booking_history["lattitude"]).not_to be_nil

                expect(booking_history["longitude"]).not_to be_nil
            end

            it "updates booking history" do
                booking_history = BookingHistory.new.find(booking["id"])
                expect(booking_history["started_at"]).not_to be_nil

                expect(booking_history["ended_at"]).not_to be_nil

                expect(booking_history["user_id"]).to eq(1)

                expect(booking_history["car_id"]).to eq(booking["car_id"])

                expect(booking_history["is_cancelled"]).to eq(false)

                expect(booking_history["amount"]).not_to be_nil 

                expect(booking_history["start_location_lattitude"]).not_to be_nil

                expect(booking_history["start_location_longitude"]).not_to be_nil

                expect(booking_history["end_location_lattitude"]).to eq(10)

                expect(booking_history["end_location_longitude"]).not_to eq(20)

            end
        end
    end

    describe 'Cancel Ride' do
        context "Once the ride is cancelled " do

            before(:all) do
                booking_2 = User.book_ride(2, 7, 3, type = nil)
                User.cancel_ride(2, booking_2["id"])
            end

            it "updates the car booking status and booking status is_cancelled true" do
                car = Car.new.find(booking["car_id"])
                expect(car["is_booked"]).to eq(false)

                expect(booking_2["is_cancelled"]).to eq(true)
            end
        end
    end
end