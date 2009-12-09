class Character < Chingu::GameObject
  has_trait :collision_detection
  has_trait :bounding_box, :scale => 0.8, :debug =>true
  attr_reader :map
  def initialize options
    super
    @map = options[:tilemap]
    @behaviours = [] #sequential behaviours
    @std_behaviours =[] #parallel behaviours that are always run
    
    @std_behaviours << TileCollisionResponse.new(:character => self)
  end
  
  def move position
    @x += position[0]
    @y += position[1]
  end
  
  def update
    super
    update_behaviours
  end
  #
  # update the behaviours -
  def update_behaviours
    @std_behaviours.each{|sb| sb.update}
    return unless @behaviours.first #dont update if there are no behaviours
    
    if @behaviours.first.update #if the behaviour returns true then it's finished - delete it
      @behaviours.delete @behaviours.first
    end
    
  end
  
  #
  # add a behaviour - takes the class and options
  def add_behaviour behaviour_class, options
    options[:character ]=self
    b = behaviour_class.new(options)
    @behaviours << b if b.kind_of? Behaviour
  end
  #
  # return the direction (:up , :down,:left, :right) of this character relative to another
  def direction_from other_character
    type = "nothing"
    
    # adding offset incase we have already intersected other_character
    offset = @speed+3
    
    if (@y+@image.height/2)-offset <= (other_character.y-other_character.image.height/2)
      type = :up
    elsif(@y-@image.height/2)+offset >= (other_character.y+other_character.image.height/2)
      type = :down
    else
      #we are neither above nor below other_character, but within it's y boundries
      if (@x+@image.width/2)-offset <=(other_character.x-other_character.image.width/2)
        type = :left
      elsif (@x-@image.width/2)+offset >=(other_character.x+other_character.image.width/2)
        type = :right
      else
        #we screwed up, probably completely inside of other_character
        puts "ohno"
      end
      type unless type.class == String
    end
     
    type 
  end
  
end
