class Recipe
  include Ripple::Document
  property :name, String
  property :subname, String
  
  key_on :name
  
  def self.load_original
    Lorenz.load

    exist_recipes = Recipe.all
    needed_recipes = Lorenz.recipes

    for_create = needed_recipes.select { |n| !exist_recipes.detect { |e| e.title == "#{n.name}::#{n.part}"  } }
    for_destroy = exist_recipes.select { |e| !needed_recipes.detect { |n| e.title == "#{n.name}::#{n.part}" } }

    for_create.each do |new_recipe|
      puts "create recipe #{new_recipe.name}::#{new_recipe.part}"
      Recipe.new(:name => new_recipe.name, :subname => new_recipe.part).save
    end

    for_destroy.each do |exist_recipe|
      puts "destroy recipe #{exist_recipe.name}"
      exist_recipe.destroy
    end
    
    VersionsSet.default.reload.set_lorenz
  end
  
  def lorenz
    @lorenz ||= Lorenz[name, subname || 'desc']
  end
  
  def title
    "#{name}::#{subname || 'desc'}"
  end
  
  def node_list
    original_recipe.node_list
  end
  
end