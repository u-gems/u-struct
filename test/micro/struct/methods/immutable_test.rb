# frozen_string_literal: true

require 'test_helper'

class Micro::Struct_Methods_Immutable_Test < Minitest::Test
  Person1 = Micro::Struct[:instance_copy].new(:first_name, :last_name)
  Person2 = Micro::Struct.immutable.new(:first_name, :last_name)

  def test_attributes_reading
    person = Person1.new(first_name: 'Rodrigo', last_name: 'Serradura')

    assert_instance_of(Person1, person)

    assert_equal('Rodrigo', person.first_name)
    assert_equal('Serradura', person.last_name)
  end

  def test_attributes_writing
    person1 = Person1.new(first_name: 'Rodrigo', last_name: 'Serradura')

    assert_equal('Rodrigo', person1.first_name)
    assert_equal('Serradura', person1.last_name)

    person1.first_name = 'Foo'
    person1.last_name = 'Bar'

    assert_equal('Foo', person1.first_name)
    assert_equal('Bar', person1.last_name)

    # ---

    person2 = Person2.new(first_name: 'Rodrigo', last_name: 'Serradura')

    error1 = assert_raises(NoMethodError) { person2.first_name = 'Bar' }

    assert_match(/private method [`']first_name=' called for .*Person2/, error1.message)

    error2 = assert_raises(NoMethodError) { person2.last_name = 'Foo' }

    assert_match(/private method [`']last_name=' called for .*Person2/, error2.message)
  end

  def test_instance_copying
    [Person1, Person2].each do |struct|
      person_a = struct.new(first_name: 'Rodrigo', last_name: 'Serradura')

      person_b = person_a.with(last_name: 'Foo')

      assert_equal('Rodrigo', person_a.first_name)
      assert_equal('Serradura', person_a.last_name)

      assert_equal('Rodrigo', person_b.first_name)
      assert_equal('Foo', person_b.last_name)

      refute_same(person_a, person_b)
    end
  end

  Person3 = Micro::Struct.immutable(with: :exposed_features).new(:first_name, :last_name)
  Person4 = Micro::Struct.immutable(with: [:exposed_features, :to_ary]).new(:first_name, :last_name)

  def test_the_adding_of_additional_features
    assert_equal(
      {to_ary: false, to_hash: false, to_proc: false, readonly: true, instance_copy: true},
      Person3.features.options
    )

    assert_equal(
      {to_ary: true, to_hash: false, to_proc: false, readonly: true, instance_copy: true},
      Person4.features.options
    )
  end
end
