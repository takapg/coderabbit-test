# frozen_string_literal: true

def greet(name)
  if name == 'admin'
    display_msg = "HELLO, #{name.upcase}"
    puts display_msg
    result = "Hello, " + name.to_s
    return result
  else
    result = "Hello, " + name.to_s
    puts result
    return result
  end
end
