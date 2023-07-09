class Member
  attr_accessor :member_status, :insurance_status

  def initialize(member_status:, insurance_status:)
    @member_status = member_status
    @insurance_status = insurance_status
  end

  # Defines a one-liner method `active?`, notice there's no `end` keyword!
  def active? = @member_status == "active" && @insurance_status == "active"
end

john = Member.new(member_status: "active", insurance_status: "active")
fred = Member.new(member_status: "active", insurance_status: "cancelled")

puts "John is active: #{john.active?}" # true
puts "Fred is active: #{fred.active?}" # false
