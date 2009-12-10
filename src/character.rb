class Character < Chingu::GameObject
  has_trait :collision_detection
  has_trait :bounding_box, :scale => 0.8, :debug =>true
  attr_reader :map
  def initialize options
    super
    @map = options[:tilemap]
    @behaviours = [] #sequential behaviours
    @std_behaviours =[] #parallel behaviours that are always run
    
    #
    # debug/dev crap
    add_std_behaviour TileCollisionResponse, {}
  end
  
  def move position
    @x += position[0]
    @y += position[1]
  end
  
  def update
    super
    update_behaviours
  end
   
  protected
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
  # add a standard behaviour - one that is never complete e.g. falling via force of gravity
  def add_std_behaviour behaviour_class, options
    options[:character ]=self
    b = behaviour_class.new(options)
    @std_behaviours << b if b.kind_of? Behaviour
  end
  
  #
  # add a behaviour - takes the class and options
  def add_behaviour behaviour_class, options
    options[:character ]=self
    b = behaviour_class.new(options)
    @behaviours << b if b.kind_of? Behaviour
  end
end
