class Placing
  attr_accessor :name, :place

  def initialize(name, place)
    @name = name
    @place = place
  end

  def mongoize
    hashh = { name: @name, place: @place }
    end

  def self.mongoize(obj)
    case obj
    when nil then nil
    when Hash then obj
    when Placing then { name: obj.name, place: obj.place }
     end
   end

  def self.demongoize(obj)
    case obj
    when nil then nil
    when Hash then Placing.new(obj[:name], obj[:place])
    when Placing then obj
     end
   end

  def self.evolve(obj)
    case obj
    when nil then nil
    when Hash then obj
    when Placing then { name: obj.name, place: obj.place }
     end
   end
  end
