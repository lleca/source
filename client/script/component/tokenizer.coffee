tokenizer = {}

do ->

  if typeof String.prototype.startsWith is 'function'
    startsWith = (text, searchvalue, start)->
      text.startsWith(searchvalue, start)
  else
    startsWith = (text, searchvalue, start)->
      start = start or 0;
      text.substring(start, searchvalue.length + start) is searchvalue

  contains = (sought, list)->
    for item in list
      if item is sought
        return true
    return false

  nextToken = (state, context)->
    area = context.text.substring(state.index)
    matchNumeric = area.match /^[0-9]+/
    if matchNumeric
      content = matchNumeric[0]
      length  = content.length
      state.next =
        type: 'NUMERIC'
        column: state.column
        line: state.line
        content: content
      state.cleanLine = false
      state.index    += length
      state.column   += length
      return
    matchId = area.match /^[_a-zA-Z][_a-zA-Z0-9]*/
    if matchId
      content    = matchId[0]
      length     = content.length
      state.next =
        column: state.column
        line: state.line
        content: content
      state.cleanLine = false
      state.index    += length
      state.column   += length
      if contains content, context.keywords
        state.next.type = 'KEYWORD'
      else
        state.next.type = 'IDENTIFIER'
      return
    matchString = area.match /^"((\\")|[^"])*"/
    unless matchString
      matchString = area.match /^'((\\')|[^'])*'/
    if matchString
      content    = matchString[0]
      length     = content.length
      state.next =
        type: 'STRING'
        column: state.column
        line: state.line
        content: content
      state.cleanLine = false
      state.index    += length
      state.column   += length
      return
    for symbol in context.symbols
      if startsWith area, symbol
        state.next =
          type: 'SYMBOL'
          column: state.column
          line: state.line
          content: symbol
        state.cleanLine = false
        state.index    += symbol.length
        state.column   += symbol.length
        return
    state.next =
      type: 'error'
      column: state.column
      line:   state.line
      content: 'Unexpected character '+ area.charAt(0)

  step = (state, context)->
    char0 = context.text.charAt(state.index)
    if char0 is ' ' or char0 is '\t'
      state.index  += 1
      state.column += 1
      return
    if char0 is '\n'
      state.index     += 1
      state.column     = 1
      state.line      += 1
      state.cleanLine  = true
      return
    if char0 is '/'
      char1 = context.text.charAt(state.index + 1)
      if char1 is '/' and state.cleanLine
        commentEnd = context.text.indexOf '\n', state.index
        state.next =
          type:    'COMMENT'
          column:  state.column
          line:    state.line
          content: context.text.substring(state.index, commentEnd)
        state.column    = 1
        state.line     += 1
        state.index     = commentEnd + 1 #remove breakline
        state.cleanLine = true
        return
      if char1 is '*'
        commentEnd = context.text.indexOf '*/', state.index
        if commentEnd is -1
          state.next =
            type: 'ERROR'
            column:  state.column
            line:    state.line
            content: 'Unterminated multiline comment'
          return
        content = context.text.substring(state.index, commentEnd + 2)
        state.next =
          type: 'COMMENT'
          multiline: true
          column: state.column
          line: state.line
          content: content
        state.column = 10 #TODO caculate
        state.cleanLine = true #TODO caculate
        state.line  += content.split('\n').length - 1
        state.index = commentEnd + 2
        return
    nextToken state, context

  tokenizer.process = (text, keywords, symbols)->
    state =
      index:  0
      column: 1
      line:   1
      cleanLine: true
    context =
      text: text
      keywords: keywords
      symbols: symbols
    next:->
      state.next = null
      while not state.next and state.index < text.length
        step state, context
      state.next
