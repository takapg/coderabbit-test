require 'minitest/autorun'
require 'stringio'

# sample.rb executes `greet("alice")` at the top level, which raises a
# NameError because of the `reslt` bug.  We suppress stdout and rescue the
# error so the file can be loaded and the `greet` method becomes available.
begin
  original_stdout = $stdout
  $stdout = StringIO.new
  require_relative '../sample'
rescue NameError
  # expected – the top-level call hits the `return reslt` bug
ensure
  $stdout = original_stdout
end

class GreetTest < Minitest::Test
  # Capture stdout during a block.
  # Returns the captured string (for non-raising callers) and also populates
  # out_ref[:output] so callers can read it even when the block raises.
  #
  #   out = {}
  #   assert_raises(NameError) { capture_output(out) { greet("alice") } }
  #   out[:output]  # => "Hello, alice\n"
  def capture_output(out_ref = nil)
    original = $stdout
    buffer   = StringIO.new
    $stdout  = buffer
    yield
    buffer.string
  ensure
    $stdout = original
    out_ref[:output] = buffer.string if out_ref
  end

  # ---------------------------------------------------------------
  # Output behaviour – regular (non-admin) names
  # ---------------------------------------------------------------

  def test_greet_regular_name_prints_hello_message
    out = {}
    assert_raises(NameError) { capture_output(out) { greet("alice") } }
    assert_equal "Hello, alice\n", out[:output]
  end

  def test_greet_non_admin_name_does_not_uppercase
    out = {}
    assert_raises(NameError) { capture_output(out) { greet("Bob") } }
    assert_equal "Hello, Bob\n", out[:output]
    refute_equal "HELLO, BOB\n", out[:output]
  end

  def test_greet_name_with_spaces_is_printed_as_is
    out = {}
    assert_raises(NameError) { capture_output(out) { greet("John Doe") } }
    assert_equal "Hello, John Doe\n", out[:output]
  end

  def test_greet_numeric_string_is_treated_as_regular_name
    out = {}
    assert_raises(NameError) { capture_output(out) { greet("42") } }
    assert_equal "Hello, 42\n", out[:output]
  end

  # ---------------------------------------------------------------
  # Output behaviour – admin branch (uppercase)
  # ---------------------------------------------------------------

  def test_greet_admin_prints_uppercased_message
    out = {}
    assert_raises(NameError) { capture_output(out) { greet("admin") } }
    assert_equal "HELLO, ADMIN\n", out[:output]
  end

  def test_greet_admin_message_entire_string_is_uppercased
    # Confirms the full composed string ("Hello, admin") is uppercased,
    # not just the name portion.
    out = {}
    assert_raises(NameError) { capture_output(out) { greet("admin") } }
    assert_equal out[:output].upcase, out[:output]
  end

  def test_greet_mixed_case_admin_is_not_treated_as_admin
    # Only the exact string "admin" triggers the uppercase branch.
    out = {}
    assert_raises(NameError) { capture_output(out) { greet("Admin") } }
    assert_equal "Hello, Admin\n", out[:output]
  end

  # ---------------------------------------------------------------
  # Edge cases
  # ---------------------------------------------------------------

  def test_greet_empty_string_prints_hello_with_no_name
    out = {}
    assert_raises(NameError) { capture_output(out) { greet("") } }
    assert_equal "Hello, \n", out[:output]
  end

  # ---------------------------------------------------------------
  # Bug documentation: `return reslt` always raises NameError
  # ---------------------------------------------------------------

  def test_greet_raises_name_error_for_regular_name
    # `reslt` is not defined anywhere; every call to greet raises NameError.
    assert_raises(NameError) { greet("alice") }
  end

  def test_greet_raises_name_error_for_admin
    assert_raises(NameError) { greet("admin") }
  end

  # ---------------------------------------------------------------
  # Type safety
  # ---------------------------------------------------------------

  def test_greet_with_nil_raises_type_error
    # String concatenation with nil raises TypeError before reaching `return reslt`.
    assert_raises(TypeError) { greet(nil) }
  end
end
