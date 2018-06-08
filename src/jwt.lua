local meta    = {}
local data    = {}

local json    = require 'cjson'
local basexx  = require 'basexx'
local jws     = require 'jwt.jws'
local jwe     = require 'jwt.jwe'
local plain   = require 'jwt.plain'

local function getJwt(options)
  if options and options.alg and options.alg ~= "none" then
    if options.enc then
      return jwe
    else
      return jws
    end
  else
    return plain
  end
end

function meta:__metatable()
  return false
end

function meta:__index(key)
  return data[key]
end

local function header(options)
  if options then
    return {
      alg = options.alg,
      enc = options.enc,
      iss = options.iss,
      aud = options.aud,
      sub = options.sub,
    }
  end
  return {}
end

function data.encode(claims, options)
  local jwt       = getJwt(options)
  local header    = basexx.to_base64(json.encode(header(options)))
  local body, err = jwt:encode(claims, options)
  if not body then return nil, err end
  return header.."."..body
end

function data.decode(str, options)
  if not str then return nil, "Parameter 1 cannot be nil" end
  local dotFirst = str:find("%.")
  if not dotFirst then return nil, "Invalid token" end
  local header = json.decode(basexx.from_base64(str:sub(1, dotFirst)))

  return getJwt(header):decode(header, str:sub(dotFirst+1), options)
end

function meta:__newindex(key)
  error('Read Only')
end

return setmetatable({}, meta)