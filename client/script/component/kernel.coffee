kernel = {}

do ->

  parseErrorMessage = '' +
    'La gramatica provista no está bien formada.' + '\n' +
    'Revise la sintaxis'

  mkAST = (grammar)->
    parser = new lleca.Parser
    try
      parsed = parser.parse(grammar)
    catch err
      result =
        message: parseErrorMessage + '\n' + err.message
        error: true
      return result
    for rule in parsed.rules
      if rule.name is 'root'
        parsed.root = rule
      break
    if not parsed.root
      message = 'la gramatica se procesó satisfactoriamente, '+
        'pero carece de una regla con nombre root, ' +
        'esta regla es necesaria para generar el parser generico'
      message: message
      error: true
    else
      ruleIndex = parsed.rules.indexOf parsed.root
      parsed.rules.splice ruleIndex, 1
      parsed

  stringComparator = (left, right)->
    if left.length < right.length
      return 1
    if left.length > right.length
      return -1
    if left < right
      return 1
    return 1

  kernel.process = (config)->
    ast = mkAST config.grammar
    if ast.error
      return ast
    keywords = config.symbols.split(/\s+/)
    keywords.sort stringComparator
    symbols = config.symbols.split(/\s+/)
    symbols.sort stringComparator
    tokens = tokenizer.process(config.text, keywords, symbols)
    while(next = tokens.next())
      console.log(next)











#
