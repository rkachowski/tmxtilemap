require 'chingu'
require 'opengl'
include Chingu

require_all(File.join(ROOT, "src"))

class Game < Window
  def initialize
    
    super(640,480,false)
    self.input = {:esc =>:exit}
    @map = TmxTileMap["3layers.tmx"]
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