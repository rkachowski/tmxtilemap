require 'rubygems'
require 'chingu'
require 'gosu'
require 'opengl'

require_all(File.join(ROOT, "src"))

class Game < Chingu::Window
  def initialize
    
    super(640,480,false)
    self.input = {:esc =>:exit, :holding_up => :uup, :holding_down => :dwn}
    @map = TmxTileMapLoader["halltest.tmx"] 
    @c = Character.create(:x=>200,:y=>350,:image=>Gosu::Image["man.png"],:tilemap=>@map)
  end
  
  def draw 
    super
    @map.draw
  end
  
  def update
    super
    self.caption = "test char / map collisions fps #{self.fps}"
  end
  def dwn ; @c.y+=2;end
  def uup ; @c.y-=2;end
end

Game.new.show