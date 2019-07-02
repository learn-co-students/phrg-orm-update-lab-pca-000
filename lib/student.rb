require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def save
    if self.id
      self.update
    end
    sql = <<-SQL
    INSERT INTO students (name, grade) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  def update
    sql = <<-SQL
    UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  class << self
    def create_table
      sql = <<-SQL
      CREATE TABLE students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
      );
      SQL
      DB[:conn].execute(sql)
    end

    def drop_table
      DB[:conn].execute("DROP TABLE IF EXISTS students")
    end

    def create(name, grade)
      student = Student.new(name, grade)
      student.save
    end

    def new_from_db(student)
      id = student[0]
      name = student[1]
      grade = student[2]
      Student.new(id, name, grade)
    end

    def find_by_name(name)
      sql = <<-SQL
      SELECT * FROM students WHERE name = ? LIMIT 1
      SQL
      DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
      end.first
    end
  end
end
