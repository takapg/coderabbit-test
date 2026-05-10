require 'minitest/autorun'

# Load sample.rb. The top-level `greet("alice")` call at the bottom of the file
# raises NameError (undefined variable `reslt`), so we rescue it here.
# The `greet` method definition at the top of the file is still registered.
begin
  require_relative 'sample'
rescue NameError
  # Expected: the top-level call raises NameError due to the `return reslt` bug.
end

class TestGreet < Minitest::Test
  # Helper: invoke greet, capturing stdout and silencing the expected NameError.
  def capture_greet(name)
    out, _err = capture_io do
      greet(name)
    rescue NameError
      # swallow so capture_io can return the captured output
    end
    out
  end

  # ------------------------------------------------------------------
  # Non-admin path: puts the plain greeting message
  # ------------------------------------------------------------------

  def test_greet_non_admin_prints_hello_message
    out = capture_greet("alice")
    assert_equal "Hello, alice\n", out
  end

  def test_greet_non_admin_output_is_not_uppercased
    out = capture_greet("bob")
    assert_equal "Hello, bob\n", out
    refute_equal "HELLO, BOB\n", out
  end

  def test_greet_non_admin_includes_name_in_output
    out = capture_greet("charlie")
    assert_includes out, "charlie"
  end

  # ------------------------------------------------------------------
  # Admin path: puts the uppercased greeting message
  # ------------------------------------------------------------------

  def test_greet_admin_prints_uppercased_message
    out = capture_greet("admin")
    assert_equal "HELLO, ADMIN\n", out
  end

  def test_greet_admin_output_is_fully_uppercase
    out = capture_greet("admin")
    assert_equal out, out.upcase
  end

  # ------------------------------------------------------------------
  # Case sensitivity: only the exact string "admin" triggers the admin branch
  # ------------------------------------------------------------------

  def test_greet_admin_check_is_case_sensitive_capital_a
    out = capture_greet("Admin")
    assert_equal "Hello, Admin\n", out
    refute_equal "HELLO, ADMIN\n", out
  end

  def test_greet_admin_check_is_case_sensitive_all_caps
    out = capture_greet("ADMIN")
    assert_equal "Hello, ADMIN\n", out
    refute_equal "HELLO, ADMIN\n", out
  end

  # ------------------------------------------------------------------
  # Return value bug: `return reslt` always raises NameError
  # ------------------------------------------------------------------

  def test_greet_raises_name_error_for_non_admin
    assert_raises(NameError) { greet("alice") }
  end

  def test_greet_raises_name_error_for_admin
    assert_raises(NameError) { greet("admin") }
  end

  def test_greet_name_error_message_references_reslt
    error = assert_raises(NameError) { greet("anyone") }
    assert_match(/reslt/, error.message,
      "NameError should mention the undefined variable 'reslt'")
  end

  # ------------------------------------------------------------------
  # Edge cases
  # ------------------------------------------------------------------

  def test_greet_empty_string
    out = capture_greet("")
    assert_equal "Hello, \n", out
  end

  def test_greet_name_with_spaces
    out = capture_greet("john doe")
    assert_equal "Hello, john doe\n", out
  end

  def test_greet_name_with_numbers
    out = capture_greet("user42")
    assert_equal "Hello, user42\n", out
  end

  def test_greet_name_with_special_characters
    out = capture_greet("alice!")
    assert_equal "Hello, alice!\n", out
  end

  # ------------------------------------------------------------------
  # Regression: puts executes before NameError is raised
  # ------------------------------------------------------------------

  def test_output_is_produced_even_though_exception_follows
    # Documents that puts runs before `return reslt` raises NameError.
    # If the bug is ever fixed (reslt -> msg), this test should still pass.
    out = capture_greet("regression_user")
    assert_equal "Hello, regression_user\n", out
  end
end
