require 'mongo'
require 'mongoid'
require 'json'
require 'pp'

class Place
  include ActiveModel::Model
  attr_accessor :id, :formatted_address, :location, :address_components
  def initialize param
    if param.nil? or param.empty?
      return nil
    else
        @id = param[:_id].to_s
        @formatted_address = param[:formatted_address]
        @address_components = param[:address_components].map do |each|
          AddressComponent.new(each)
        end unless param[:address_components].nil?
        @location = Point.new(param[:geometry][:geolocation])
    end
  end
    
  def persisted?
    !@id.nil?
  end

  def self.mongo_client
    Mongoid::Clients.default
  end

  def self.collection
    @@coll = mongo_client[:places]
  end

  def self.load_all file
    file = File.read(file)
    data = JSON.parse(file)
    collection.insert_many(data)
  end
    
  def self.find_by_short_name short_name
    collection.find('address_components.short_name': short_name)
  end

  def self.to_places view
    coll = []
    view.each { |doc| coll << Place.new(doc) }
    return coll
  end
    
  def self.find id
    id = BSON::ObjectId.from_string(id) if id.is_a? String
    result = self.collection.find({:_id => id}).first
    return result.nil? ? nil : Place.new(result)
  end

  def self.all(offset=0, limit=0)
    docs = collection.find.skip(offset).limit(limit)
    all_places = []
    docs.each { |doc| all_places << Place.new(doc) }
    return all_places
  end

  def destroy
    id = BSON::ObjectId.from_string(@id)
    @@coll.delete_one(_id: id)
  end

  def self.get_address_components(sort={}, offset=0, limit=0)
    aggregate_arry = [{:$unwind => "$address_components"},
                            {:$project => {"_id" => 1, "address_components" => 1,
                                "formatted_address" => 1, "geometry.geolocation" => 1}}]
    aggregate_arry << {:$sort => sort} unless sort == {}
    aggregate_arry << {:$skip => offset} unless offset == 0
    aggregate_arry << {:$limit => limit} unless limit == 0
    collection.aggregate(aggregate_arry)
  end

  def self.get_country_names
    aggregate_arry = [{:$unwind =>  "$address_components"},
                      {:$project => {"address_components.long_name" => 1,
                                     "address_components.types" => 1}},
                      {:$match => {"address_components.types" => "country"}},
                      {:$group => {_id: "$address_components.long_name" }}]
    collection.aggregate(aggregate_arry).to_a.map {|h| h[:_id]}
  end

  def self.find_ids_by_country_code country_code
    aggregate_arry = [{:$match => {"address_components.types" => "country",
                                   "address_components.short_name" => country_code}},
                      {:$project => {_id: 1}}]
    collection.aggregate(aggregate_arry).to_a.map {|doc| doc[:_id].to_s}
                      
  end

  def self.create_indexes
    collection.indexes.create_one({"geometry.geolocation" => Mongo::Index::GEO2DSPHERE})
  end

  def self.remove_indexes
    idx = Place.collection.indexes.map {|r| r[:name]}[1]
    collection.indexes.drop_one(idx)
  end

  def self.near(point, max_meters=-1)
    find_query = {"geometry.geolocation" => {:$near => {:$geometry => point.to_hash }}}
    find_query["geometry.geolocation"][:$near][:$maxDistance] = max_meters unless max_meters == -1
    collection.find(find_query)
  end

  def near(max_meters=-1)
    self.class.to_places(self.class.near(@location, max_meters))
  end

  def photos(offset=0, limit=0)
    Photo.find_photos_for_place(@id).map{ |doc| Photo.new(doc) }
  end
end
