List = require './list'

module.exports = (models, model, returns) ->

  (res, fn) ->
    res.text = ''
    res.setEncoding 'utf8'
    
    res.on 'data', (chunk) ->
      res.text += chunk

    res.on 'end', ->

      body = res.text and JSON.parse res.text 

      if res.statusCode >= 400
        if typeof body == 'object' and body.error
          err = new Error body.error.message 

          for key of body.error
            err[key] = body.error[key]

        else
          err = new Error 'Error: ' + res.statusCode 
          err.statusCode = res.statusCode
          err.details = body
        
        return fn null, err

      for name, { root, type } of returns

        if not root
          body = body[name]
 
        ctor = models[name] or 
               models[type] or 
               model 

        if Array.isArray body 
          body = new List body, ctor
        else 
          body = new ctor body
 
      fn null, body

    return