require 'exifr/jpeg'
require 'mongoid'
require 'mongo'

class Photo
  attr_accessor :id, :location
  attr_writer :contents
  def initialize(doc={})
    # if doc.nil?
      # return nil
    if doc.empty?
      return nil
    else
      @id = doc[:_id].to_s
      @location = Point.new(doc[:metadata][:location])
      @place = doc[:metadata][:place]
    end
  end

  def self.mongo_client
    Mongoid::Clients.default
  end

  def persisted?
    !@id.nil?
  end

  def save
    if self.persisted?
      id = BSON::ObjectId.from_string(@id)
      metadata = {location: @location.to_hash, place: @place}
      self.class.mongo_client.database.fs.find(_id: id).update_one(metadata: metadata)
    else
      gps=EXIFR::JPEG.new(@contents).gps
      @contents.rewind
      @location=Point.new(:lng=>gps.longitude, :lat=>gps.latitude)
      description = {}
      description[:metadata] = {location: @location.to_hash, place: @place}
      description[:content_type] = "image/jpeg"
      grid_file = Mongo::Grid::File.new(@contents.read, description)
      id = self.class.mongo_client.database.fs.insert_one(grid_file)
      @id = id.to_s
    end
  end

  def self.all(offset=0, limit=0)
    all = mongo_client.database.fs.find.skip(offset).limit(limit).map{|doc| Photo.new(doc)}
  end

  def self.find id
    id = BSON::ObjectId.from_string(id)
    res = mongo_client.database.fs.find(_id: id).first
    return res.nil? ? nil : self.new(res)
  end

  def contents
    id = BSON::ObjectId.from_string(@id)
    f = self.class.mongo_client.database.fs.find_one(_id: id)
    if f
      buffer = ""
      f.chunks.reduce([]) {|x, chunk| buffer << chunk.data.data}
      return buffer
    end
  end

  def place
    # @place
    Place.find @place
    # return place.nil? ? nil : BSON::ObjectId.from_string(place.id)
  end

  def place= object
    if object.is_a? String
      place_id = BSON::ObjectId.from_string(object)
    elsif object.is_a? Place
      place_id = BSON::ObjectId.from_string(object.id)
    else
      place_id = object
    end
    @place = place_id
  end

  def destroy
    id = BSON::ObjectId.from_string(@id)
    f = self.class.mongo_client.database.fs.find(_id: id).delete_one
  end

  def find_nearest_place_id max_distance
    place_coll = Place.near(@location, max_distance).limit(1).projection({_id: 1}).first[:_id]
    return place_coll.nil? ? nil : place_coll
  end

  def self.find_photos_for_place id
    id = BSON::ObjectId.from_string(id) if id.is_a? String
    mongo_client.database.fs.find({"metadata.place" => id})
  end
end
