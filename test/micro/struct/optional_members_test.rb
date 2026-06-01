# frozen_string_literal: true

require 'test_helper'

class Micro::Struct_OptionalMembers_Test < Minitest::Test
  Person0 = Micro::Struct.new(optional: [:first_name, :last_name])
  Person1 = Micro::Struct.new(required: :first_name, optional: :last_name)
  Person2 = Micro::Struct.with(:readonly).new(:first_name, optional: [:last_name])

  def test_the_constructor
    person0 = Person0.new

    assert_instance_of(Person0, person0)

    assert_nil(person0.first_name)
    assert_nil(person0.last_name)

    # --

    [Person1, Person2].each do |struct|
      person = struct.new(first_name: 'Rodrigo')

      assert_instance_of(struct, person)

      assert_equal('Rodrigo', person.first_name)
      assert_nil(person.last_name)
    end

    # --

    [Person1, Person2].each do |mod|
      error = assert_raises(ArgumentError) { mod.new }

      assert_match(/missing keyword: :?first_name/, error.message)
    end
  end

  def test_attributes_reading
    [Person0, Person1, Person2].each do |struct|
      person = struct.new(first_name: 'Rodrigo', last_name: 'Serradura')

      assert_instance_of(struct, person)

      assert_equal('Rodrigo', person.first_name)
      assert_equal('Serradura', person.last_name)
    end
  end

  def test_attributes_writing
    [Person0, Person1].each do |struct|
      person = struct.new(first_name: 'Rodrigo', last_name: 'Serradura')

      assert_instance_of(struct, person)

      assert_equal('Rodrigo', person.first_name)

      person.first_name = 'Digo'

      assert_equal('Digo', person.first_name)
    end

    # ---

    person2 = Person2.new(first_name: 'Rodrigo', last_name: 'Serradura')

    error1 = assert_raises(NoMethodError) { person2.first_name = 'Bar' }

    assert_match(/private method [`']first_name=' called for .*Person2/, error1.message)

    error2 = assert_raises(NoMethodError) { person2.last_name = 'Foo' }

    assert_match(/private method [`']last_name=' called for .*Person2/, error2.message)
  end

  def test_the_struct_members
    [Person0, Person1, Person2].each do |struct|
      assert_equal([:first_name, :last_name], struct.members)
    end
  end

  def test_the_struct_triple_equal
    [Person0, Person1, Person2].each do |struct|
      person = struct.new(first_name: '', last_name: '')

      assert(struct === person)
    end
  end
end
