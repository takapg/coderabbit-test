# frozen_string_literal: true

def greet(name)
  result = "Hello, #{name}"
  if name == 'admin'
    puts "HELLO, #{name.upcase}"
  else
    puts result
  end
  result
end
