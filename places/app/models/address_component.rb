class AddressComponent
  attr_reader :long_name, :short_name, :types
  def initialize param
    @long_name = param[:long_name]
    @short_name = param[:short_name]
    @types = param[:types]
  end

end
