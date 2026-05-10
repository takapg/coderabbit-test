def greet(name)
  msg = "Hello, " + name

  if name == "admin"
    puts msg.upcase()
  else
    puts msg
  end

  return msg
end
