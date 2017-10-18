window.ERROR_ELEMENT =

  NO_SE_PUEDE_PARSEAR_LA_LINEA:
    context:
      rawLine: 'Linea original ingresada'
      parseError: 'Error del componente de parseo'
    content:
      '${rawLine} \n' +
      'no responde a una fórmula bien formada.' + '\n' +
      'Revise la sintaxis' + '\n' +
      '${parseError}'

for errorName of window.ERROR_ELEMENT
  errorElement = window.ERROR_ELEMENT[errorName]
  errorElement.name = errorName
  errorElement.type = 'ERROR'
