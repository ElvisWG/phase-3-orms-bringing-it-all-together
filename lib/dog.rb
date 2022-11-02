require "pry"

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

    # Drops a table if it already exists on the database
    def self.drop_table
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs;
        SQL
    
        # Execute SQL statement for dropping a table if exists
        DB[:conn].execute(sql)
      end

      def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
            SQL
    
        # This statement create a new table if it does not exist on the database
        DB[:conn].execute(sql)
      end

       # Saves the attributes of a DOG objects into the database
  def save
    if self.id.nil?
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

      # Inserts the attributes of the dog that is the name and breed into the table dogs as a row
      DB[:conn].execute(sql, self.name, self.breed)

      # Gets the id given to the row that was inserted into the table
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").first[0]

      # The object is returned

    else
      self.update
    end
    self
  end

  def self.create(name:, breed:)
    # Create a new instance of a Dog
    dog = Dog.new(name: name, breed: breed)

    # Saves the attributes of the Dog instance into the database
    dog.save
  end

    #creates object from row
    def self.new_from_db(row)
             self.new(id: row[0], name: row[1], breed: row[2])
      end
      def self.all
        sql = <<-SQL
        SELECT * FROM dogs;
        SQL
    
        DB[:conn].execute(sql).map do |row|
          self.new_from_db(row)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs
        where name = ?
        LIMIT 1;
        SQL
    
        # Returns first object that matches passed name
        DB[:conn].execute(sql, name).map do |row|
          self.new_from_db(row)
        end.first
    end

    def self.find(id)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map do |row|
          self.new_from_db(row)
        end.first
      end
end
