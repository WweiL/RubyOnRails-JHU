class Point
  attr_accessor :longitude, :latitude

  def initialize param
    if param[:coordinates]
      @longitude = param[:coordinates][0]
      @latitude = param[:coordinates][1]
    else
      @longitude = param[:lng]
      @latitude = param[:lat]
    end
  end

  def to_hash
    return {:type => "Point", :coordinates => [@longitude, @latitude]}
  end

end
