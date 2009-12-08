class TileMap < Chingu::BasicGameObject
  def initialize options
    @size = options[:size]
    @width = @size[0]
    @height = @size[1]
    
    @x = 0
    @y=0
    
    #initialize map
    @map = Array.new(@width){Array.new(@height){Tile.new(:x=>8)}}
    @map.each_index{|j| @map[j].each_index{|i| @map[j][i].y = i *@map[j][i].image.height + @map[j][i].image.height/2 ; @map[j][i].x =j *@map[j][i].image.width + @map[j][i].image.width/2  } } # set initial positions of tiles
    super
  end
  
  def draw
    super
    @map.each{|x| x.each{|y| y.draw unless y == nil}}
    
  end
  
  #
  # move the entire map d =  [x,y] pixels
  def move d
    return unless d.is_a? Array and d.size == 2
    
    @map.each do |a| 
      a.each do |t|  
        if t
          t.x +=d[0]
          t.y +=d[1]
        end
      end
    end

    @x += d[0]
    @y += d[1]
  end
  
  def get_drawable_grid
    get_map_cell [0,0]
    get_map_cell [@width-1,@height-1]
  end
  
  #
  # given coordinates, return the cell that this maps to
  def get_map_cell position
    return unless position.is_a? Array and position.size == 2
    x,y = position[0]-@x,position[1]-@y
    x = (x.to_f/Tile.const_get("TILE_WIDTH")).floor
    y = (y.to_f/Tile.const_get("TILE_HEIGHT")).floor
    [x,y]
  end
  
end
