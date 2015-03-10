class Recipe
  attr_reader :id, :name, :description, :instructions, :ingredients

  def initialize(id, name, description = nil, instructions = nil, ingredients = [])
    @id = id
    @name = name
    @description = description || "This recipe doesn't have a description."
    @instructions = instructions || "This recipe doesn't have any instructions."
    @ingredients = ingredients
  end

  def self.db_connection
    begin
      connection = PG.connect(dbname: "recipes")
      yield(connection)
    ensure
      connection.close
    end
  end

  def self.all
    recipes = []
    Recipe.db_connection do |conn|
      recipes = conn.exec("SELECT name, id FROM recipes")
    end
    recipes.to_a.map { |recipe| Recipe.new(recipe["id"], recipe["name"])}
  end

  def self.find(id)
    recipe = nil
    ingredients = nil
    Recipe.db_connection do |conn|
      recipe = conn.exec_params("SELECT * FROM recipes WHERE id = $1", [id])
      ingredients = conn.exec_params("SELECT name FROM ingredients WHERE recipe_id = $1", [id])
    end
    recipe = recipe.to_a[0] || {}
    ingredients = ingredients.to_a.map { |ingredient| Ingredient.new(ingredient["name"])}
    Recipe.new(recipe["id"], recipe["name"], recipe["description"], recipe["instructions"], ingredients)
  end
end
