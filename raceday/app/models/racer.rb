require 'mongo'
require 'pp'
class Racer
  include ActiveModel::Model
  attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

  def initialize(params={})
    @id=params[:_id].nil? ? params[:id] : params[:_id].to_s
    @number=params[:number].to_i
    @first_name=params[:first_name]
    @last_name=params[:last_name]
    @gender=params[:gender]
    @group=params[:group]
    @secs=params[:secs].to_i
  end

  def self.mongo_client
    Mongoid::Clients.default
  end

  def self.collection
    self.mongo_client[:racers]
  end

  def persisted?
    !@id.nil?
  end

  def created_at
    nil
  end
  
  def updated_at
    nil
  end

  def self.all(prototype={}, sort={number: 1}, skip=0, limit=nil)
    limit = 0 if limit == nil
    attrs = [:_id, :number, :first_name, :last_name, :gender, :group, :secs]
    tmp = {}
    sort.each do |k, v|
      tmp[k] = v if attrs.include?(k)
    end
    sort = tmp
    tmp = {}
    prototype.each do |k, v|
      tmp[k] = v if attrs.include?(k)
    end
    prototype = tmp
    return self.collection.find(prototype).sort(sort).skip(skip).limit(limit)
  end

  def self.find(id)
    id = BSON::ObjectId.from_string(id) if id.is_a? String
    result = self.collection.find({:_id => id}).first
    return result.nil? ? nil : Racer.new(result)
  end

  def save
    params = {number: @number, first_name: @first_name, last_name: @last_name, \
                gender: @gender, group: @group, secs: @secs}
    result=self.class.collection.insert_one(params)
    result = self.class.collection.find(params).first
    @id=result[:_id].to_s
  end

  def update(params)
    @number=params[:number].to_i
    @first_name=params[:first_name]
    @last_name=params[:last_name]
    @gender=params[:gender]
    @group=params[:group]
    @secs=params[:secs].to_i
  
    params.slice!(:number, :first_name, :last_name, :gender, :group, :secs)
    id = BSON::ObjectId.from_string(@id) if @id.is_a? String
    self.class.collection.find(_id: id).update_one(params)
  end

  def destroy
    id = BSON::ObjectId.from_string(@id) if @id.is_a? String
    self.class.collection.delete_one(_id: id)
  end

# accept a hash as input parameters

# • extract the :page property from that hash, convert to an integer, and default to the value of 1 if not set.
#
# • extract the :per_page property from that hash, convert to an integer, and default to the value of 30 if not set
#
# • ﬁnd all racers sorted by number assending.
#
# • limit the results to page and limit values.
# • convert each document hash to an instance of a Racer class
# • Return a WillPaginate::Collection with the page, limit, and total values ﬁlled in
#  – as well as the page worth of data.
  def self.paginate(params)
    page=(params[:page] || 1).to_i
    limit=(params[:per_page] || 30).to_i
    skip=(page-1)*limit
    racers=[]
    self.all({}, {}, skip, limit).each do |doc|
      racers << Racer.new(doc)
    end
    total=self.all.count
    WillPaginate::Collection.create(page, limit, total)do |pager|
      pager.replace(racers)
    end
  end
end
