
local srcs = {'init.lua', 'main.lua'}
for i=1, #srcs do
  if file.exists(srcs[i]) then
    node.compile(srcs[i])
    file.remove(srcs[i])
  end
end

print('Hello World')

-- dofile('main.lc')
