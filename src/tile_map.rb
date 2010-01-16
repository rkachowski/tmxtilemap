#
# An arrangement of tiles
class TileMap < Chingu::BasicGameObject
  attr_accessor :map,:name,:tids
  attr_reader :x,:y
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
    @map.each_index{|j| @map[j].each_index{|i| @map[j][i].y = i *Tile.const_get("TILE_HEIGHT") + Tile.const_get("TILE_HEIGHT")/2 ; @map[j][i].x =j *Tile.const_get("TILE_WIDTH") + Tile.const_get("TILE_WIDTH")/2  } } # set initial positions of tiles
    get_drawable_grid
    
    @tileset = nil
  end
  
  def size
    @width*@height
  end
  
  def add_tileset options

    fail("tileset cannot added before tids (tile id's) are defined") unless @tids
    
    @tileset = TileSet.new(:tids=>@tids,:tilesets=>options)
  end
  
  #
  #given a point, return a value that says whether this space is free or not
  def solid_point? position
    #puts position
    cell = get_map_cell(position)
    @map[cell[0]][cell[1]].solid
  end
  
  #
  #create a tileset and assign each tile a face from it
  def set_tiles array, tileset_info
    fail("wrong sized tile info given to map") unless array.size == size
    
    add_tileset tileset_info
    t =0
    @height.times{|h| @map.each{|w| w[h].set_info array[t],@tileset;t+=1}} #breadth first through a 2d array - feels dubious...
    
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
    @map[@min_x..@max_x].each{|x| x[@min_y..@max_y].each{|y| y.draw }} unless @min_x > @max_x
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
  def max_y nv ; nv <= @height-1 ? @max_y =nv : @max_y = @height-1 end
  
  #
  # given coordinates, return the cell that this maps to
  def get_map_cell position
    return unless position.is_a? Array and position.size == 2
    x,y = position[0]-@x,position[1]-@y
    x = (x.to_f/Tile.const_get("TILE_WIDTH")).floor
    y = (y.to_f/Tile.const_get("TILE_HEIGHT")).floor
    [x,y]
  end
  
  #
  #given a set of coordinates, return whether there is a tile there.
  #used for scrolling
  #(empty tiles count as tiles)
  def tile_exists_at? position
    c = get_map_cell position
    c[0] >=0 and c[0] <@width-1 and c[1] >=0 and c[1] <=@height-1
  end
  
  #
  # returns the tile at this position, used for collision response
  def get_tile_at position
    c = get_map_cell position
    @map[c[0]][c[1]]
  end
  
  class TileSet
    attr_reader :name
    include Chingu::NamedResource
   
    TileSet.autoload_dirs = [ File.join("media","maps")]

    def self.find(name)
      (path = find_file(name)) ? path : nil
    end
    
    def initialize options
      @tids = options[:tids]
      sets = []
      options[:tilesets].each do |ts|
        image = ts[:image].split('/').last
        #name = ts[:name] || "nonameset"
        ftid = ts[:firstid] || 1
        sets <<{:image =>image,:name=>name,:ftid=>ftid, :spacing =>ts[:spacing]}
      end
      
      #load all tiles from tileset images
      sets.each do |s|
        sp = s[:spacing] || 0 #gosu doesnt handle spaced tiles :(
        s[:tiles] =Gosu::Image.load_tiles($window,TileSet.find(s[:image]),Tile.const_get('TILE_WIDTH'),Tile.const_get('TILE_HEIGHT'),true)
      end
      
      ##keep only the tiles used in the map
      @tiles = {}
      @tids.each do |x|
        next if x ==0
        #find which set x is in
        ind = 0
        
        sets.each{|s| x < s[:ftid] ? lambda{ind = sets.index(s)-1;break} : ind = sets.index(s)}
        
        tiles = sets[ind][:tiles] # the set x is found in
        index = x - sets[ind][:ftid] # the index of x in the set
        
        @tiles[x]=tiles[index] unless x ==0 
      end
      #@tiles[x]= tiles[x-1] unless x==0
    end
    
    #
    #given a tile number, return an image that maps to it
    def get_tile tile_no
      @tiles[tile_no] ? @tiles[tile_no] : fail("tile #{tile_no} does not exist in map #{@name}")
    end
  end
  
  class Tile 
    attr_accessor :solid, :x,:y,:image, :name, :type, :tileset
    def initialize options
      @name = options[:name] || "t_default.png"
      @solid = true
      @x = 0
      @y = 0
    end
    
    def set_info type, tileset
      @type = type
      type ==0 ? empty : @image = tileset.get_tile(type)
    end
      
    def empty
      @solid = false
      @image = nil
    end
    
    def draw
      @image.draw(@x-TILE_WIDTH/2,@y-TILE_HEIGHT/2,5) if @image
    end
    
    def t
      @y-TILE_HEIGHT/2
    end
    def b
      @y+TILE_HEIGHT/2
    end
    def l
      @x -TILE_WIDTH/2
    end
    def r
      @x + TILE_WIDTH/2
    end
    
  end
  
end
