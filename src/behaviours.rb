#
#A base class to encapsulate character behaviour
#
class Behaviour
  attr_reader :finished
  def initialize options
    @character = options[:character]
    @finished = false
  end
  
  def position
    [@character.x,@character.y]
  end
  
  def update
    @finished
  end
  
end

#
# A behaviour that moves the character towards the player
class MoveToPlayer < Behaviour
  MIN_DISTANCE = 5 # minimum distance allowed between player and character
  
  def initialize options
    super
    @player = options[:player]
  end
    
  def update
    xcomp = @player.x - @character.x
    ycomp = @player.y - @character.y
    distance = Math.sqrt((xcomp)**2+(ycomp)**2)
    #puts distance
    if distance > MIN_DISTANCE
      @character.x += xcomp/distance*@character.speed
      @character.y += ycomp/distance*@character.speed
    else @finished = true
    end
    super
  end
  
end

#
# a behaviour that moves the character towards a point
class MoveToPoint < Behaviour
  MIN_DISTANCE = 5 # minimum distance allowed between character and point
  def initialize options
    super
    @x = options[:x]
    @y = options[:y]
  end
  
  def update
    xcomp = @x - @character.x
    ycomp = @y - @character.y
    distance = Math.sqrt((xcomp)**2+(ycomp)**2)
    
    if distance > MIN_DISTANCE
      @character.x += xcomp/distance*@character.speed
      @character.y += ycomp/distance*@character.speed
    else @finished = true
    end
    super
  end
end
#
# a behaviour that makes tiles collideable
class TileCollisionResponse < Behaviour
  def initialize options
    super
  end
  
  def update
    c_points =[ [@character.x,@character.bb.t],[@character.x,@character.bb.b],[@character.bb.l,@character.y],[@character.bb.r,@character.y] ]
    c_points.map!{|p| p =@character.map.solid_point?(p) }
    
    $window.fill_rect(Chingu::Rect.new(@character.x-1,@character.y-1,3,3),0xffffffff,500)
    
    c_points.each_with_index do |c,i|
      if c
        case i
          when 0 
            #up
            @character.y=@character.map.get_tile_at([@character.x,@character.bb.t]).b + @character.bb.h/2
          when 1 
            #down
            @character.y = @character.map.get_tile_at([@character.x,@character.bb.b]).t - @character.bb.h/2
          when 2 
          #left
          when 3 
          #right
        end
      end
    end
    
   super 
  end
  
end




