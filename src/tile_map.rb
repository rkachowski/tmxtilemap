#
# An arrangement of tiles
class TileMap < Chingu::BasicGameObject
  attr_accessor :map,:name
  def initialize options
    @size = options[:size]
    @width = @size[0]
    @height = @size[1]
    super
    
    Tile.const_set("TILE_WIDTH",options[:tilesize][0])
    Tile.const_set("TILE_HEIGHT",options[:tilesize][1])
    
    @x = 0
    @y = 0
    
    @name = "noname"
    #initialize map
    @map = Array.new(@width){Array.new(@height){Tile.new(:x=>8)}}
    @map.each_index{|j| @map[j].each_index{|i| @map[j][i].y = i *@map[j][i].image.height + @map[j][i].image.height/2 ; @map[j][i].x =j *@map[j][i].image.width + @map[j][i].image.width/2  } } # set initial positions of tiles
    get_drawable_grid
  end
  
  def size
    @width*@height
  end
  
  #
  #given an array of numbers, assign each tile in the map a type
  def set_tiles array
    fail("wrong sized tile info given to map") unless array.size == size
    t =0
    @height.times{|h| @map.each{|w| w[h].type = array[t];t+=1}} #breadth first through a 2d array - feels dubious...
  end
  
  #
  #an iterator to access each tile in the map (depth first)
  def each_tile &block
    @map.each{|x| x.each{|y| yield y}}
  end
  
  #
  #draw everytile that is visible on screen
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
  
  class TileSet
    def initialize options
      #tile image
      #name
      #dimensions
      #array of rectangles corresponding to tiles
    end
    
    #
    #given a tile number, return an instance of Tile
    def get_tile tile_no
    end
  end
  
  class Tile 
    attr_accessor :solid, :x,:y,:image, :name, :type
    def initialize options
      @type = 0
      @name = options[:name] || "t_default.png"
      @image = Gosu::Image[@name].retrofy
      @solid = true
      @x = 0
      @y = 0
    end
    
    def draw
      @image.draw(@x-TILE_WIDTH/2,@y-TILE_HEIGHT/2,0)
    end
  
  end
  
end
