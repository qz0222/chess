require 'byebug'
class Employee

  attr_reader :name, :title, :salary, :boss

  def initialize(name, title, salary, boss)
    @name = name
    @title = title
    @salary = salary
    self.boss = boss
  end

  def boss=(boss)
    @boss = boss
    boss.list << self unless boss.nil?
  end

  def bonus(multiplier)
    salary * multiplier
  end

end

class Manager < Employee

  attr_accessor :list

  def initialize(name, title, salary, boss)
    super(name, title, salary, boss)
    @list = []
  end

  def bonus(multiplier)
    total = 0

    list.each do |sub_employee|
      total += sub_employee.salary
      total += sub_employee.bonus(1) if sub_employee.is_a?(Manager)
    end

    total * multiplier
  end

end

ned = Manager.new('Ned', 'Founder', 1_000_000, nil)
darren = Manager.new('Darren', 'TA Manager', 78000, ned)
shawna = Employee.new('Shawna', 'TA', 12000, darren)
david = Employee.new('David', 'TA', 10000, darren)

p ned.bonus(5)
p darren.bonus(4)
p david.bonus(3)
