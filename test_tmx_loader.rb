require 'rubygems'
require 'chingu'
require 'gosu'
require 'opengl'

require_all(File.join(ROOT, "src"))

class Game < Chingu::Window
  def initialize
    
    super(640,480,false)
    self.input = {:esc =>:exit}
    @map = TmxTileMapLoader["mult2.tmx"]
  end
  
  def draw 
    super
    @map.draw
  end
  
  def update
    super
    #@map.move [-1,0]
    self.caption = "test .tmx loading fps #{self.fps}"
  end
  
end

Game.new.show