
window.addLoadListener ->
  validateElem = document.querySelector('#validate')
  parser = new lleca.Parser
  ###
  for example, index in validate
    ast = validator.validate(example, parser)
    if ast
      viewer.process(ast)
      ast.root.view.title = example
      container = document.createElement 'div'
      container.classList.add 'validate-container'
      codeElem = document.createElement 'pre'
      container.appendChild codeElem
      container.appendChild ast.root.view
      rawContent = document.createTextNode example
      codeElem.appendChild rawContent
      validateElem.appendChild container
    else
      validateElem.appendChild document.createTextNode('error al procesar')
  ###

validate = [

  " 1:¬r premisa      \n" +
  " 2:q premisa       \n" +
  " 3:q→r supuesto    \n" +
  " 4:¬r R(1)         \n" +
  " 5:r E→(2,3)       \n" +
  " 6:⊥ E¬(4,5)       \n" +
  " <<                \n" +
  " 7:¬(q→r) I¬(3-6)   "

]
