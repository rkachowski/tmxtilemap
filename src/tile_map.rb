class TileMap < Chingu::BasicGameObject
  def initialize options
    @size = options[:size]
    @width = @size[0]
    @height = @size[1]
    
    @x = 0
    @y=0
    
    get_drawable_grid
    
    #initialize map
    @map = Array.new(@width){Array.new(@height){Tile.new(:x=>8)}}
    @map.each_index{|j| @map[j].each_index{|i| @map[j][i].y = i *@map[j][i].image.height + @map[j][i].image.height/2 ; @map[j][i].x =j *@map[j][i].image.width + @map[j][i].image.width/2  } } # set initial positions of tiles
    super
  end
  
  def draw
    super
    @map[@min_x..@max_x].each{|x| x[@min_y..@max_y].each{|y| y.draw unless y == nil}} unless @min_x > @max_x
    
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
    
    get_drawable_grid
  end
  
  #
  # finds the visible area of the tile map, so we dont draw tiles that are off screen
  def get_drawable_grid
    min = get_map_cell [0,0]
    max = get_map_cell [$window.width-1,$window.height-1]
    min_x min[0]
    max_x max[0]
    min_y min[1]
    max_y max[1]
  end
  
  #
  # methods to handle the range of input on drawable map
  def min_x nv ; nv >= 0 ? @min_x =nv : @min_x = 0 end
  def min_y nv ; nv >= 0 ? @min_y =nv : @min_y = 0 end
  def max_x nv ; nv <= @width-1 ? @max_x =nv : @max_x = @width-1 end
  def max_y nv ; nv <= @height-1 ? @max_y =nv : @min_y = @height-1 end
  
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
