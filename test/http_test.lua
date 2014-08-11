local uv = require 'uv'
local http = require 'uv.http'

--------------------------------------------------------------------------------
-- basic server
--------------------------------------------------------------------------------

uv.run(function()
  local server = http.server(uv.loop)
  server:bind('127.0.0.1', 7000)
  server:listen(function(request)
    return 200, {}, 'hello world'
  end)

  local client = uv.tcp():connect('127.0.0.1', 7000).handle
  client:write('GET / HTTP/1.1\n\n')
  local response = client:read()
  assert(response:find('HTTP/1.1 200 OK'))
  assert(response:find('hello world'))
  client:close()

  server:close()
end)

--------------------------------------------------------------------------------
-- middleware
--------------------------------------------------------------------------------

local function with_access_log(print, yield)
  return function(request)
    local status, headers, body = yield(request)

    print(string.format('%s - - [%s] "%s %s" %s %i %q %q',
          request.socket:getpeername(),
          os.date("!%Y-%m-%dT%TZ"),
          request.method, request.url, status, #body,
          request.headers['Referer'] or '-',
          request.headers['User-Agent'] or '-'))

    return status, headers, body
  end
end

uv.run(function()
  local access_log = ''
  local function append_to_log(line)
    access_log = access_log .. line .. '\n'
  end

  local server = http.server(uv.loop)
  server:bind('127.0.0.1', 7000)
  server:listen(with_access_log(append_to_log, function(request)
    return 200, {}, 'hello world'
  end))

  local client = uv.tcp():connect('127.0.0.1', 7000).handle
  client:write('GET / HTTP/1.1\n\n')
  local response = client:read()
  client:close()

  assert(access_log:match('^127.0.0.1 %- %- %[.+%] "GET /" 200 11 "%-" "%-"\n$'))

  server:close()
end)