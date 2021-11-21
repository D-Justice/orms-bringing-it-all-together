class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id, @name, @breed = id, name, breed
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end
    def save
        if self.id
            self.update
        else
            DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            
        end
        self
    end
    def self.create(hash)
        newInstance = self.new(name: hash[:name], breed: hash[:breed])
        newInstance.save
    end
    def self.new_from_db(row)
        newInstance = self.new(id: row[0], name: row[1], breed: row[2])
        newInstance.save
    end

    def self.find_by_id(id)
        self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0])
    end

    def self.find_or_create_by(name:, breed:)
    exists = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if exists.empty?
        newInstance = self.new(name: name, breed: breed)
        newInstance.save
    else
        newInstance = self.new_from_db(exists[0])
    end

    newInstance

    end
    def self.find_by_name(name)
        newInstance = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
        newInstance = self.new_from_db(newInstance)
    end
    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
        
    end
end
