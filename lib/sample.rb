# frozen_string_literal: true

def greet(name)
  if name == 'admin'
    result = "HELLO, #{name.upcase}"
    puts result
    return result
  else
    result = "Hello, " + name.to_s
    puts result
    return result
  end
end
