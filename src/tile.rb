class Tile < Chingu::GameObject
  attr_accessor :solid
  TILE_WIDTH = 16
  TILE_HEIGHT = 16
  def initialize options
    super
    @image = Gosu::Image["t_default.png"]
    @solid = true
    
  end
end
