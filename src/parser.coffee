List = require './list'

module.exports = (model, returns, body, statusCode) ->
  try
    body = body and JSON.parse body
  catch e
    e.context = body
    console.error e

  if statusCode >= 400
    if typeof body == 'object' and body.error
      err = new Error body.error.message

      for key of body.error
        err[key] = body.error[key]

    else
      err = new Error 'Error: ' + statusCode
      err.statusCode = statusCode
      err.details = body

    return err

  for { name, root, type } in returns

    if not root
      body = body[name]

    if type is 'object'
      ctor = Object
    else if model.name is type
      ctor ?= model

    { models } = model

    ctor ?= models[name] or
            models[type] or
            model

    opts = defaults: false

    if ctor
      if Array.isArray body
        body = new List body, ctor, null, opts
      else
        body = new ctor body, opts

  body
