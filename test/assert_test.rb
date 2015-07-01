require 'minitest/autorun'
require 'mocha/mini_test'
require 'assert'

class TestMeme < Minitest::Test
  attr_reader :subject

  def setup
    @subject = Object.new
    @subject.extend(::Assert)
  end

  def test_assert
    subject.expects(:assert).with(2)
    subject.assert! { 1 + 1 }
  end

  def test_refute_equal
    subject.expects(:refute_equal).with(1, 2)
    subject.assert! { 1 != 2 }
  end

  def test_assert_equal
    subject.expects(:assert_equal).with(1, 2)
    subject.assert! { 1 == 2 }
  end

  def test_assert_operator
    subject.expects(:assert_operator).with(1, :>=, 2)
    subject.assert! { 1 >= 2 }

    subject.expects(:assert_operator).with(1, :<=, 2)
    subject.assert! { 1 <= 2 }

    subject.expects(:assert_operator).with(1, :<, 2)
    subject.assert! { 1 < 2 }

    subject.expects(:assert_operator).with(1, :>, 2)
    subject.assert! { 1 > 2 }
  end

  def test_assert_empty
    array = []
    subject.expects(:assert_empty).with(array)
    subject.assert! { array.empty? }
  end

  def test_assert_includes
    array = [1]
    subject.expects(:assert_includes).with(array, 1)
    subject.assert! { array.include?(1) }
  end

  def test_assert_instance_of
    subject.expects(:assert_instance_of).with(Integer, 1)
    subject.assert! { 1.instance_of?(Integer) }
  end

  def test_assert_kind_of
    subject.expects(:assert_kind_of).with(Numeric, 1)
    subject.assert! { 1.kind_of?(Numeric) }
  end

  def test_assert_match
    subject.expects(:asset_match).with(/test/, 'test')
    subject.assert! { 'test' =~ /test/ }
  end

  def test_assert_nil
    subject.expects(:assert_nil).with(nil)
    subject.assert! { nil.nil? }
  end

  def test_assert_respond_to
    subject.expects(:assert_respond_to).with(nil, :test)
    subject.assert! { nil.respond_to? :test }
  end

end

