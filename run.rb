require 'rubygems'
require 'chingu'
require 'gosu'
require 'opengl'

require_all(File.join(ROOT, "src"))

class Game < Chingu::Window
  def initialize
    super(640,480,false)
    self.input = {:esc =>:exit,:left_mouse_button=>:click, :left=>:m_left}
    @j = TileMap.create(:size => [40,30])
    
  end
  
  def m_left
    @j.move [-1,0]
  end
  
  def update
    super
    self.caption = "tile test fps:#{self.fps}"
    
  end
  
  def click
    puts @j.get_map_cell [mouse_x,mouse_y]
  end
  
end


Game.new.show 
