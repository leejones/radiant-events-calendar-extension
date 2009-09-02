module AssetEventAssociations
  
  def self.included(base)
    base.class_eval {
      has_one :Event
    }
  end
  
end