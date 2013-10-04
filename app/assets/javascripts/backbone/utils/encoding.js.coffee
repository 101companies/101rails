Wiki.Utils.atTo101 = (s) ->
  match = /@(.*)/.exec(s)
  if not match or Wiki.Utils.validateEmail(s)
    s
  else
    '101' + match[1]

# http://stackoverflow.com/questions/46155/validate-email-address-in-javascript
Wiki.Utils.validateEmail = (email) ->
  re = /\S+@\S+\.\S+/
  re.test email

Wiki.Utils.escapeURI = (uri) ->
  decodeURIComponent(uri
    .replace(/\-/g, '-2D')
    .replace(/\:/g, "-3A")
    .replace(/\s/g, '_')
    .replace(/\'/g, '-27')
  )
