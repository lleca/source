
helpers_1 = {}

helpers_1.escapeString = (str) ->
  str.replace '"', '"'

###
# Determines if a value is an object
###

helpers_1.isObject = (value) ->
  type = typeof value
  ! !value and type == 'object'

###
# Gets constructor name of an object.
# From http://stackoverflow.com/a/332429
#
###

helpers_1.getObjectName = (object) ->
  if object == undefined
    return ''
  if object == null
    return 'Object'
  if typeof object == 'object' and !object.constructor
    return 'Object'
  funcNameRegex = /function ([^(]*)/
  results = funcNameRegex.exec(object.constructor.toString())
  if results and results.length > 1
    results[1]
  else
    ''

###
# Gets type of an object. Returns "null" for null objects
###

helpers_1.getType = (object) ->
  if object == null
    return 'null'
  typeof object

###
# Generates inline preview for a JavaScript object based on a value
###

helpers_1.getValuePreview = (object, value) ->
  type = helpers_1.getType(object)
  if type == 'null' or type == 'undefined'
    return type
  if type == 'string'
    value = '"' + helpers_1.escapeString(value) + '"'
  if type == 'function'
    # Remove content of the function
    return object.toString().replace(/[\r\n]/g, '').replace(/\{.*\}/, '') + '{…}'
  value

###
# Generates inline preview for a JavaScript object
###

helpers_1.getPreview = (object) ->
  value = ''
  if isObject(object)
    value = helpers_1.getObjectName(object)
    if Array.isArray(object)
      value += '[' + object.length + ']'
  else
    value = helpers_1.getValuePreview(object, object)
  value

###
# Generates a prefixed CSS class name
###

helpers_1.cssClass = (className) ->
  'json-formatter-' + className

###
  * Creates a new DOM element wiht given type and class
  * TODO: move me to helpers
###

helpers_1.createElement = (type, className, content) ->
  el = document.createElement(type)
  if className
    el.classList.add helpers_1.cssClass(className)
  if content != undefined
    if content instanceof Node
      el.appendChild content
    else
      el.appendChild document.createTextNode(String(content))
  el

# ---
# generated by js2coffee 2.2.0



DATE_STRING_REGEX = /(^\d{1,4}[\.|\\/|-]\d{1,2}[\.|\\/|-]\d{1,4})(\s*(?:0?[1-9]:[0-5]|1(?=[012])\d:[0-5])\d\s*[ap]m)?$/
PARTIAL_DATE_REGEX = /\d{2}:\d{2}:\d{2} GMT-\d{4}/
JSON_DATE_REGEX = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z/
# When toggleing, don't animated removal or addition of more than a few items
MAX_ANIMATED_TOGGLE_ITEMS = 10
requestAnimationFrame = window.requestAnimationFrame or (cb) ->
  cb()
  0
_defaultConfig =
  hoverPreviewEnabled: false
  hoverPreviewArrayCount: 100
  hoverPreviewFieldCount: 5
  animateOpen: true
  animateClose: true
  theme: null


JSONFormatter = do ->

  JSONFormatterInstance = (json, open, config, key) ->
    if open == undefined
      open = 1
    if config == undefined
      config = _defaultConfig
    @json = json
    @open = open
    @config = config
    @key = key
    # Hold the open state after the toggler is used
    @_isOpen = null
    # Setting default values for config object
    if @config.hoverPreviewEnabled == undefined
      @config.hoverPreviewEnabled = _defaultConfig.hoverPreviewEnabled
    if @config.hoverPreviewArrayCount == undefined
      @config.hoverPreviewArrayCount = _defaultConfig.hoverPreviewArrayCount
    if @config.hoverPreviewFieldCount == undefined
      @config.hoverPreviewFieldCount = _defaultConfig.hoverPreviewFieldCount
    return

  Object.defineProperty JSONFormatterInstance.prototype, 'isOpen',
    get: ->
      if @_isOpen != null
        @_isOpen
      else
        @open > 0
    set: (value) ->
      @_isOpen = value
      return
    enumerable: true
    configurable: true
  Object.defineProperty JSONFormatterInstance.prototype, 'isDate',
    get: ->
      @type == 'string' and (DATE_STRING_REGEX.test(@json) or JSON_DATE_REGEX.test(@json) or PARTIAL_DATE_REGEX.test(@json))
    enumerable: true
    configurable: true
  Object.defineProperty JSONFormatterInstance.prototype, 'isUrl',
    get: ->
      @type == 'string' and @json.indexOf('http') == 0
    enumerable: true
    configurable: true
  Object.defineProperty JSONFormatterInstance.prototype, 'isArray',
    get: ->
      Array.isArray @json
    enumerable: true
    configurable: true
  Object.defineProperty JSONFormatterInstance.prototype, 'isObject',
    get: ->
      helpers_1.isObject @json
    enumerable: true
    configurable: true
  Object.defineProperty JSONFormatterInstance.prototype, 'isEmptyObject',
    get: ->
      !@keys.length and !@isArray
    enumerable: true
    configurable: true
  Object.defineProperty JSONFormatterInstance.prototype, 'isEmpty',
    get: ->
      @isEmptyObject or @keys and !@keys.length and @isArray
    enumerable: true
    configurable: true
  Object.defineProperty JSONFormatterInstance.prototype, 'hasKey',
    get: ->
      typeof @key != 'undefined'
    enumerable: true
    configurable: true
  Object.defineProperty JSONFormatterInstance.prototype, 'constructorName',
    get: ->
      helpers_1.getObjectName @json
    enumerable: true
    configurable: true
  Object.defineProperty JSONFormatterInstance.prototype, 'type',
    get: ->
      helpers_1.getType @json
    enumerable: true
    configurable: true
  Object.defineProperty JSONFormatterInstance.prototype, 'keys',
    get: ->
      if @isObject
        Object.keys(@json).map (key) ->
          if key then key else '""'
      else
        []
    enumerable: true
    configurable: true

  ###*
  # Toggles `isOpen` state
  #
  ###

  JSONFormatterInstance::toggleOpen = ->
    @isOpen = !@isOpen
    if @element
      if @isOpen
        @appendChildren @config.animateOpen
      else
        @removeChildren @config.animateClose
      @element.classList.toggle helpers_1.cssClass('open')
    return

  ###*
  * Open all children up to a certain depth.
  * Allows actions such as expand all/collapse all
  *
  ###

  JSONFormatterInstance::openAtDepth = (depth) ->
    if depth == undefined
      depth = 1
    if depth < 0
      return
    @open = depth
    @isOpen = depth != 0
    if @element
      @removeChildren false
      if depth == 0
        @element.classList.remove helpers_1.cssClass('open')
      else
        @appendChildren @config.animateOpen
        @element.classList.add helpers_1.cssClass('open')
    return

  ###*
  # Generates inline preview
  #
  # @returns {string}
  ###

  JSONFormatterInstance::getInlinepreview = ->
    _this = this
    if @isArray
      # if array length is greater then 100 it shows "Array[101]"
      if @json.length > @config.hoverPreviewArrayCount
        'Array[' + @json.length + ']'
      else
        '[' + @json.map(helpers_1.getPreview).join(', ') + ']'
    else
      keys = @keys
      # the first five keys (like Chrome Developer Tool)
      narrowKeys = keys.slice(0, @config.hoverPreviewFieldCount)
      # json value schematic information
      kvs = narrowKeys.map((key) ->
        key + ':' + helpers_1.getPreview(_this.json[key])
      )
      # if keys count greater then 5 then show ellipsis
      ellipsis = if keys.length >= @config.hoverPreviewFieldCount then '…' else ''
      '{' + kvs.join(', ') + ellipsis + '}'

  ###*
  # Renders an HTML element and installs event listeners
  #
  # @returns {HTMLDivElement}
  ###

  JSONFormatterInstance::render = ->
    `var value`
    # construct the root element and assign it to this.element
    @element = helpers_1.createElement('div', 'row')
    # construct the toggler link
    togglerLink = helpers_1.createElement('a', 'toggler-link')
    # if this is an object we need a wrapper span (toggler)
    if @isObject
      togglerLink.appendChild helpers_1.createElement('span', 'toggler')
    # if this is child of a parent formatter we need to append the key
    if @hasKey
      togglerLink.appendChild helpers_1.createElement('span', 'key', @key + ':')
    # Value for objects and arrays
    if @isObject
      # construct the value holder element
      value = helpers_1.createElement('span', 'value')
      # we need a wrapper span for objects
      objectWrapperSpan = helpers_1.createElement('span')
      # get constructor name and append it to wrapper span
      constructorName = helpers_1.createElement('span', 'constructor-name', @constructorName)
      objectWrapperSpan.appendChild constructorName
      # if it's an array append the array specific elements like brackets and length
      if @isArray
        arrayWrapperSpan = helpers_1.createElement('span')
        arrayWrapperSpan.appendChild helpers_1.createElement('span', 'bracket', '[')
        arrayWrapperSpan.appendChild helpers_1.createElement('span', 'number', @json.length)
        arrayWrapperSpan.appendChild helpers_1.createElement('span', 'bracket', ']')
        objectWrapperSpan.appendChild arrayWrapperSpan
      # append object wrapper span to toggler link
      value.appendChild objectWrapperSpan
      togglerLink.appendChild value
      # Primitive values
    else
      # make a value holder element
      value = if @isUrl then helpers_1.createElement('a') else helpers_1.createElement('span')
      # add type and other type related CSS classes
      value.classList.add helpers_1.cssClass(@type)
      if @isDate
        value.classList.add helpers_1.cssClass('date')
      if @isUrl
        value.classList.add helpers_1.cssClass('url')
        value.setAttribute 'href', @json
      # Append value content to value element
      valuePreview = helpers_1.getValuePreview(@json, @json)
      value.appendChild document.createTextNode(valuePreview)
      # append the value element to toggler link
      togglerLink.appendChild value
    # if hover preview is enabled, append the inline preview element
    if @isObject and @config.hoverPreviewEnabled
      preview = helpers_1.createElement('span', 'preview-text')
      preview.appendChild document.createTextNode(@getInlinepreview())
      togglerLink.appendChild preview
    # construct a children element
    children = helpers_1.createElement('div', 'children')
    # set CSS classes for children
    if @isObject
      children.classList.add helpers_1.cssClass('object')
    if @isArray
      children.classList.add helpers_1.cssClass('array')
    if @isEmpty
      children.classList.add helpers_1.cssClass('empty')
    # set CSS classes for root element
    if @config and @config.theme
      @element.classList.add helpers_1.cssClass(@config.theme)
    if @isOpen
      @element.classList.add helpers_1.cssClass('open')
    # append toggler and children elements to root element
    @element.appendChild togglerLink
    @element.appendChild children
    # if formatter is set to be open call appendChildren
    if @isObject and @isOpen
      @appendChildren()
    # add event listener for toggling
    if @isObject
      togglerLink.addEventListener 'click', @toggleOpen.bind(this)
    @element

  ###*
  # Appends all the children to children element
  # Animated option is used when user triggers this via a click
  ###

  JSONFormatterInstance::appendChildren = (animated) ->
    _this = this
    if animated == undefined
      animated = false
    children = @element.querySelector('div.' + helpers_1.cssClass('children'))
    if !children or @isEmpty
      return
    if animated
      index_1 = 0

      addAChild_1 = ->
        key = _this.keys[index_1]
        formatter = new JSONFormatterInstance(_this.json[key], _this.open - 1, _this.config, key)
        children.appendChild formatter.render()
        index_1 += 1
        if index_1 < _this.keys.length
          if index_1 > MAX_ANIMATED_TOGGLE_ITEMS
            addAChild_1()
          else
            requestAnimationFrame addAChild_1
        return

      requestAnimationFrame addAChild_1
    else
      @keys.forEach (key) ->
        formatter = new JSONFormatterInstance(_this.json[key], _this.open - 1, _this.config, key)
        children.appendChild formatter.render()
        return
    return

  ###*
  # Removes all the children from children element
  # Animated option is used when user triggers this via a click
  ###

  JSONFormatterInstance::removeChildren = (animated) ->
    if animated == undefined
      animated = false
    childrenElement = @element.querySelector('div.' + helpers_1.cssClass('children'))
    if animated
      childrenRemoved_1 = 0

      removeAChild_1 = ->
        if childrenElement and childrenElement.children.length
          childrenElement.removeChild childrenElement.children[0]
          childrenRemoved_1 += 1
          if childrenRemoved_1 > MAX_ANIMATED_TOGGLE_ITEMS
            removeAChild_1()
          else
            requestAnimationFrame removeAChild_1
        return

      requestAnimationFrame removeAChild_1
    else
      if childrenElement
        childrenElement.innerHTML = ''
    return

  JSONFormatterInstance

# ---
# generated by js2coffee 2.2.0
