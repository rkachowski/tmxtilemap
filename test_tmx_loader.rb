require 'rubygems'
require 'chingu'
require 'gosu'
require 'opengl'

require_all(File.join(ROOT, "src"))

class Game < Chingu::Window
  def initialize
    
    super(640,480,false)
    self.input = {:esc =>:exit}
    @map = TmxTileMapLoader.load("testy.tmx")
    puts @map.tids
  end
  
  def draw 
    super
    @map.draw
  end
  
end

Game.new.show