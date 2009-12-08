class Tile 
  attr_accessor :solid, :x,:y,:image
  TILE_WIDTH = 16
  TILE_HEIGHT = 16
  def initialize options
    
    @image = Gosu::Image["t_default.png"]
    @solid = true
    @x = 0
    @y = 0
  end
  
  def draw
    @image.draw(@x,@y,0)
  end
  
end
