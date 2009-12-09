require 'stringio'
require 'base64'
require 'zlib'
require 'rubygems'
require 'nokogiri'

# load a tmx file (produced by Tiled map editor mapeditor.org )
# return a TileMap and TileSets that match tmx info
class TmxTileMapLoader
  def initialize file
    file = File.new file
    doc = Nokogiri::XML file
    
    #extract info from tmx file
    tmx_info = parse_tmx doc
    #create a map along tmx definitions
    map = create_map tmx_info[:global]
    #fill map with tile data
    fill_map map, tmx_info[:layers]
    #create tilesets
  end
    
  #
  # take tmx map info and decode it
  def uncode_map_info data
    data = Base64.decode64(data)
    data = StringIO.new(data)
    data = Zlib::GzipReader.new(data)
  end
  
  #
  #take info (name,dimensions etc) and return a TileMap that meets this
  def create_map info
    map = TileMap.new(:size=>[info[:width],info[:height]],:tilesize=>[info[:tile_width],info[:tile_height]])
    #create tilesets
    map
  end
  
  #
  # take map and fill it with tile info
  def fill_map map, info
    #NOTE: we are currently only supporting one tile layer
    map_data = uncode_map_info info[0][:data]
    map_data = map_data.to_a[0]#assuing only one line of data - map_data is now a String of size n_tiles*4 
    
    r =Range.new(0,map_data.size,true)
    tiles =[]
    r.step(4){|i| tiles << map_data[i]}#extracting the first of every 4 bytes (we only care about the tile face)
    map.set_tiles tiles
  end
    
  #
  #take a tmx file and extract what we want
  def parse_tmx xml_data
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
