require 'stringio'
require 'zlib'
require 'nokogiri'

# load a tmx file (produced by Tiled map editor mapeditor.org )
# return a TileMap and TileSets that match tmx info
class TmxTileMapLoader
  include Chingu::NamedResource
  
  TmxTileMapLoader.autoload_dirs = [ File.join("media","maps"),"maps",ROOT]
  
  def self.autoload(name)
      (path = find_file(name)) ? load(path) : nil
  end
    
  def self.load file
    file = File.new file
    doc = Nokogiri::XML file
    
    #extract info from tmx file
    tmx_info = parse_tmx doc
    #create a map along tmx definitions
    map = create_map tmx_info[:global]
    #fill map with tile data
    fill_map map, tmx_info[:layers], tmx_info[:tilesets].first
    map
  end
    
  #
  # take tmx map info and decode it
  def self.uncode_map_info data
    data= data.unpack('m')
    data = StringIO.new(data.join)
    data = Zlib::GzipReader.new(data)
  end
  
  #
  #take info (name,dimensions etc) and return a TileMap that meets this
  def self.create_map info
    TileMap.new(:size=>[info[:width],info[:height]],:tilesize=>[info[:tile_width],info[:tile_height]])
  end
  
  #
  # take map and fill it with tile layout info
  def self.fill_map map, info, tileset
    #NOTE: we are currently only supporting one tile layer
    map_data = uncode_map_info info.first[:data]
    map_data = map_data.to_a.first#assuming only one line of data - map_data is now a String of size n_tiles*4 
    tiles = map_data.bytes.to_a #get byte data of each char
    
    #we only care about the first of every 4 bytes, so clear the rest
    0.upto(tiles.size){|i| tiles[i] = nil unless i%4==0}
    tiles.compact!
    
    #add the tile info to our map
    map.set_tiles tiles,tileset
    
    #add tile ids
    map.tids= tiles.uniq
  end
    
  #
  #create a tileset and add it to a map
  def self.add_tileset tileset_info
    map.add_tileset
  end
   
  #
  #take a tmx file and extract what we want
  def self.parse_tmx xml_data
    map = xml_data.xpath('map')
    
    #get global map info
    global = {}
    global[:width] = map.attribute('width').to_s.to_i
    global[:height] = map.attribute('height').to_s.to_i
    global[:tile_width] = map.attribute('tilewidth').to_s.to_i
    global[:tile_height] = map.attribute('tileheight').to_s.to_i
      
    #get info for each tileset
    tilesets = []
    map.xpath('tileset').each do |t| 
      name = t.attribute('name').to_s
      image = t.xpath('image').attribute('source').to_s
      
      tilesets << {:name =>name,:image =>image}
    end
    
    #get info for each layer
    layers = []
    map.xpath('layer').each do |l| 
      name = l.attribute('name').to_s
      data = l.xpath('data')
      enc = data.attribute('encoding').to_s
      comp = data.attribute('compression').to_s
      data = data.text.strip!
      enc = true if enc == "base64"
      comp = true if enc == "gzip"
      
      layers << {:name=>name,:data=>data,:enc=>enc,:comp=>comp}
    end
    {:tilesets=>tilesets,:layers=>layers,:global =>global}
  end
  
  
end
