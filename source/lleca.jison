/* description: Parses a shipping DSL. */

/* lexical grammar */
%lex
%%

\s+                                               /* skip whitespace */

'['                                                  return '['
']'                                                  return ']'
'('                                                  return '('
')'                                                  return ')'
'|'                                                  return '|'
','                                                  return ','
'$'                                                  return '$'
'_'                                                  return '_'
'=>'                                                 return '=>'
'ID'                                                 return 'ID_LITERAL'
'STRING'                                             return 'STRING_LITERAL'
'NUM'                                                return 'NUM_LITERAL'



[0-9]+                                               return 'NUMERIC'
[a-zA-Z]([a-zA-Z0-9_]*)                              return 'IDENTIFIER'
\"[^"]+\"               yytext = yytext.slice(1,-1); return 'STRING'
<<EOF>>                                              return 'EOF'

%                                                    return 'INVALID'

/lex

%start start

/* declarations */

%{



%}

%% /* language grammar */

start          : EOF
                 { return { rules: [] }; }
               | gramatica EOF
                 { return { rules: $1 }; }
               ;

gramatica      : rule
                 { $$ = [$1]; }
               | rule gramatica
                 { $2.unshift($1), $$ = $2 }
               ;

rule           : IDENTIFIER productions
                 { $$ = { name: $1, productions: $2}; }
               ;

productions    : production
                 { $$ = [$1]; }
               | production productions
                 { $2.unshift($1), $$ = $2; }
               ;

production     : '|' symbols '=>' term
                 { $$ = { symbols: $2, term: $4 }; }
               | '|' '=>' term
                 { $$ = { term: $3 }; }
               ;

symbols        : symbol
                 { $$ = [$1]; }
               | symbol symbols
                 { $2.unshift($1), $$ = $2 }
               ;

symbol         : 'ID_LITERAL'
                 { $$ = { type: 'LITERAL', value: 'ID' }; }
               | 'STRING_LITERAL'
                 { $$ = { type: 'LITERAL', value: 'STRING' }; }
               | 'NUM_LITERAL'
                 { $$ = { type: 'LITERAL', value: 'NUM' }; }
               | IDENTIFIER
                 { $$ = { type: 'IDENTIFIER', value: $1 }; }
               | STRING
                 { $$ = { type: 'STRING', value: $1 }; }
               ;

term           : '_'
                 { $$ = '_'; }
               | IDENTIFIER
                 { $$ = { type: 'IDENTIFIER', value: $1 }; }
               | IDENTIFIER '(' ')'
                 { $$ = { type: 'IDENTIFIER', value: $1, arguments: [] }; }
               | IDENTIFIER '(' arguments ')'
                 { $$ = { type: 'IDENTIFIER', value: $1, arguments: $3 }; }
               | STRING
                 { $$ = { type: 'STRING', value: $1 }; }
               | NUMERIC
                 { $$ = { type: 'NUMERIC', value: $1 }; }
               | '$' NUMERIC
                 { $$ = { type: 'REFERENCE', value: $2 }; }
               | '$' NUMERIC '[' term ']'
                 { $$ = { type: 'REFERENCE', value: $2, replacement: $4 }; }
               ;

arguments      : term
                 { $$ = [$1]; }
               | term ',' arguments
                 { $3.unshift($1), $$ = $3 }
               ;




%% /**/
