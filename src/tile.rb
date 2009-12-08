class Tile 
  attr_accessor :solid, :x,:y,:image, :name
  TILE_WIDTH = 16
  TILE_HEIGHT = 16
  HALF_WIDTH = TILE_WIDTH/2
  HALF_HEIGHT = TILE_HEIGHT/2
  def initialize options
    
    @name = options[:name] || "t_default.png"
    @image = Gosu::Image[@name].retrofy
    @solid = true
    @x = 0
    @y = 0
  end
  
  def draw
    @image.draw(@x-HALF_WIDTH,@y-HALF_HEIGHT,0)
  end
  
end
