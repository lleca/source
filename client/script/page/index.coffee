load         = -> ''
save         = ->
inputChange  = ->
process      = ->
writeInput   = ->
inputMode    = ->

window.addLoadListener ->

  addClasses = (element, classes)->
    classes ?= []
    for klass in classes
      element.classList.add klass
    element

  addChildren = (element, children)->
    children ?= []
    for child in children
      element.appendChild child
    element

  mkElem = (name, children, classes)->
    elem = document.createElement name
    addChildren elem, children
    addClasses elem, classes
    elem

  mkParagraph = (text, classes)->
    paragraph = document.createElement 'p'
    text = document.createTextNode text
    paragraph.appendChild text
    addClasses paragraph, classes
    paragraph


  input        = document.querySelector('#input')
  process      = document.querySelector('#process')
  output       = document.querySelector('#output')
  menu         = document.querySelector('#menu')

  writeInput = (text)->
    text = text or ''
    #IE support
    if document.selection
      input.focus()
      sel = document.selection.createRange()
      sel.text = text
    #MOZILLA and others
    else if (input.selectionStart or input.selectionStart is '0')
      startPos = input.selectionStart
      endPos = input.selectionEnd
      input.value = input.value.substring(0, startPos) + text + input.value.substring(endPos, input.value.length)
      input.selectionEnd = endPos + text.length
    else
      input.value += text
    inputChange()
    input.focus()

  MODE =
    INPUT:   'input-mode'
    OUTPUT:  'output-mode'
  MODE.CURRENT = MODE.INPUT

  INPUT_MODE =
    TEXT:     'text'
    GRAMMAR:  'grammar'
    KEYWORDS: 'keywords'
    SYMBOLS:  'symbols'
  INPUT_MODE.CURRENT = INPUT_MODE.GRAMMAR

  swapMode = (state)->
    document.body.classList.remove MODE.CURRENT
    MODE.CURRENT = state
    document.body.classList.add MODE.CURRENT

  swapInputMode = (state)->
    menu.classList.remove 'show-'+INPUT_MODE.CURRENT
    INPUT_MODE.CURRENT = state
    input.value = load()
    menu.classList.add 'show-'+INPUT_MODE.CURRENT

  ast = null

  firstTime = ->
    window.location = 'first.html'
  fullView = ->
    document.body.classList.add('full')

  if typeof window.localStorage isnt 'undefined'
    storageKey  = 'derivation.code'
    storage = (key, value)->
      if(value)
        localStorage.setItem storageKey+key, value
      else
        localStorage.getItem storageKey+key
    save = (code) ->
      storage INPUT_MODE.CURRENT, code
    load = ->
      storage INPUT_MODE.CURRENT
    inputChange = -> save input.value
    visitKey    = 'derivation.visit'
    if not localStorage.getItem visitKey
      localStorage.setItem visitKey, true
      firstTime()
    fullKey     = 'derivation.full'
    if not localStorage.getItem fullKey
      listener = ()->
        document.removeEventListener("click", listener)
        localStorage.setItem fullKey, true
        fullView()
      document.addEventListener("click", listener);
    else
      fullView()
  else
    firstTime()

  input.value = load()

  previousActiveElement = null

  mousedownHandler = (evn)->
    previousActiveElement = document.activeElement
  process.addEventListener 'mousedown', mousedownHandler, false

  parseErrorMessage = '' +
    'La gramatica provista no está bien formada.' + '\n' +
    'Revise la sintaxis'

  stringComparator = (left, right)->
    if left.length < right.length
      return 1
    if left.length > right.length
      return -1
    if left < right
      return 1
    return 1

  processors =
    keywords: (evn)->
      keywordsError = false
      keywords = input.value.split(/\s+/)
      keywords.sort stringComparator
      output.appendChild mkElem 'div', [
        mkParagraph keywords.join(' - '), ['keywords-value']
      ], [
        'grammar-' + if keywordsError then 'error' else 'success'
      ]
      previousActiveElement.focus()
      evn.preventDefault()
    symbols: (evn)->
      symbolsError = false
      symbols = input.value.split(/\s+/)
      symbols.sort stringComparator
      output.appendChild mkElem 'div', [
        mkParagraph symbols.join(' - '), ['symbols-text']
      ], [
        'grammar-' + if symbolsError then 'error' else 'success'
      ]
      previousActiveElement.focus()
      evn.preventDefault()
    text: (evn)->
      textError = false
      keywords = storage 'keywords'
      symbols  = storage 'symbols'
      text     = storage 'text'
      grammar  = storage 'grammar'
      kernel.process(
        keywords: keywords
        symbols:  symbols
        text:     text
        grammar:  grammar
      )

      output.appendChild mkElem 'div', [
        mkParagraph input.value, ['text-text']
        mkParagraph input.value, ['text-text']
      ], [
        'grammar-' + if textError then 'error' else 'success'
      ]
      previousActiveElement.focus()
      evn.preventDefault()
    grammar: (evn)->
      parser = new lleca.Parser
      try
        parsed = parser.parse(input.value)
      catch err
        parseError = true
        output.appendChild \
          mkElem  \
            'div', \
            (mkParagraph line for line in (parseErrorMessage + '\n' + err.message ).split('\n')), \
            ['grammar-error']
      unless parseError
        for rule in parsed.rules
          if rule.name is 'root'
            parsed.root = rule
          break
        if parsed.root
          label = 'la gramatica se procesó satisfactoriamente'
          ruleIndex = parsed.rules.indexOf parsed.root
          parsed.rules.splice ruleIndex, 1
        else
          rootError = true
          label = 'la gramática se procesó satisfactoriamente, '+
            'pero carece de una regla con nombre root, ' +
            'esta regla es necesaria para generar el parser generico'

        formatter = new JSONFormatter(parsed);
        output.appendChild mkElem 'div', [
            mkParagraph label, ['grammar-text']
            mkElem 'div', [formatter.render()], ['grammar-json']
          ], [
            'grammar-' + if rootError then 'error' else 'success'
          ]
      previousActiveElement.focus()
      evn.preventDefault()
      swapMode(MODE.OUTPUT)

  processHandler = (evn)->
    while output.firstChild
      output.removeChild output.firstChild
    processors[INPUT_MODE.CURRENT](evn)

  process.addEventListener 'click', processHandler, false


  window.inputMode = ->
    swapMode(MODE.INPUT)

  window.outputMode = ->
    swapMode(MODE.OUTPUT)

  window.grammarMode = ->
    swapInputMode(INPUT_MODE.GRAMMAR)
  window.keywordsMode = ->
    swapInputMode(INPUT_MODE.KEYWORDS)
  window.symbolsMode = ->
    swapInputMode(INPUT_MODE.SYMBOLS)
  window.textMode = ->
    swapInputMode(INPUT_MODE.TEXT)

  actions = []
  ###
    keyCode: 69 #e
    char: '→'
  ,
    keyCode: 82 #r
    char: '⊥'
  ,
    keyCode: 68 #d
    char: 'V'
  ,
    keyCode: 70 #f
    char: 'Λ'
  ,
    keyCode: 71 #g
    char: '¬'
  ###


  handleKey = (evnt)->
    unless evnt.ctrlKey then return true
    keyCode = evnt.keyCode
    for action in actions
      if action.keyCode is keyCode
        writeInput action.char
        evnt.preventDefault()
        evnt.stopPropagation()
        return true

  input.addEventListener 'keydown', handleKey, false
