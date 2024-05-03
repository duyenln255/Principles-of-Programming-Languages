grammar ZCode;

@lexer::header {
from lexererr import *
}

options {
	language=Python3;
}

// --------------------------  Syntax structure ----------------------- //

// declared program
//HKT
//program: (ignore | decl)+ EOF;
//decl: function | variables;
program: NEWLINE* list_declared EOF;
list_declared:  declared list_declared |  declared;
declared: function | variables ignore;

//declared variable
variables: implicit_var | keyword_var | implicit_dynamic;
implicit_var: VAR ID ASSIGNINIT expr;
//keyword_var: typ ID (LBRACKET list_numberlit RBRACKET)? (ASSIGNINIT expr)?;
keyword_var: 
      typ ID
    | typ ID (LBRACKET list_numberlit RBRACKET)
    | typ ID (ASSIGNINIT expr)
    | typ ID (LBRACKET list_numberlit RBRACKET) (ASSIGNINIT expr);
list_numberlit: NUMBER_LIT number_lit_prime | ;
number_lit_prime: COMMA NUMBER_LIT number_lit_prime | ;
//list_numberlit: NUMBER_LIT COMMA list_numberlit | NUMBER_LIT;
typ: BOOL | NUMBER | STRING;
//implicit_dynamic: DYNAMIC ID (ASSIGNINIT expr)?;
implicit_dynamic: 
      DYNAMIC ID
    | DYNAMIC ID (ASSIGNINIT expr);

// declared function
//function: FUNC ID LPAREN prameters_list RPAREN (ignore? return_stmt | ignore? block_stmt | ignore);
function: 
      FUNC ID LPAREN prameters_list RPAREN (return_stmt)
    | FUNC ID LPAREN prameters_list RPAREN (ignore return_stmt)
    | FUNC ID LPAREN prameters_list RPAREN (block_stmt)
    | FUNC ID LPAREN prameters_list RPAREN (ignore block_stmt)
    | FUNC ID LPAREN prameters_list RPAREN (ignore);
prameters_list: prameter prameterprime |;
prameterprime: COMMA prameter prameterprime|;
//prameter: typ ID (LBRACKET list_numberlit RBRACKET)?;
prameter: 
      typ ID
    | typ ID (LBRACKET list_numberlit RBRACKET);


// expression
expr: expr0;
expr0: expr1 CONCAT expr1 | expr1;
expr1: expr2 
    (EQUAL| EQUALITY | NOTEQUAL | LESS | GREATER | LESSEQUAL | GREATEREQUAL) 
    expr2| expr2;
expr2: expr2 (AND|OR) expr3 | expr3;
expr3: expr3 (PLUS|MINUS) expr4 | expr4;
expr4: expr4 (MULTIPLY|DIVIDE|MODULUS) expr5 | expr5;
expr5: NOT expr5 | expr6;
expr6: (PLUS | MINUS) expr6 | expr7;

expr7: indexOp | expr8;
expr8: ID | literal | functionCall | subExpr;
functionCall: ID LPAREN expr_list RPAREN;
expr_list: expr exprprime |;
exprprime: COMMA expr exprprime |;
indexOp: (ID | functionCall) LBRACKET op_idx RBRACKET;
//op_idx: expr COMMA op_idx | expr;
op_idx: arrElem COMMA op_idx | arrElem;
arrElem: expr | array_literal;
subExpr:LPAREN expr RPAREN;

// Value (Literals)
literal: NUMBER_LIT | STRING_LIT | TRUE | FALSE | array_literal;
array_literal: LBRACKET op_idx RBRACKET;

//  Statements
stmt: declaration_stmt | assignment_stmt 
            | if_stmt | for_stmt 
            | break_stmt | continue_stmt 
            | return_stmt  | call_stmt | block_stmt;
declaration_stmt: variables ignore;
assignment_stmt : lhs ASSIGNINIT expr ignore;
//lhs: ID (indexp)?;
lhs: 
      ID
    | ID (indexp);
indexp: LBRACKET indexlist RBRACKET;
indexlist: expr COMMA indexlist | expr;


//if_stmt: IF ifcondition ignore? stmt (ELIF ifcondition ignore? stmt)* (ELSE ignore? stmt)?;
if_stmt: IF ifPart elifParts elsePart;
ifPart: ifcondition nlAndStmt;
elifParts: elifpart elifParts |;
elifpart: ELIF ifcondition nlAndStmt;
nlAndStmt: stmt | ignore stmt;
elsePart: ELSE nlAndStmt | ;
ifcondition: LPAREN expr RPAREN;
for_stmt: FOR ID UNTIL expr BY expr nlAndStmt ignore?;

break_stmt: BREAK ignore;
continue_stmt: CONTINUE ignore;
return_stmt: RETURN expr? ignore;
call_stmt: ID LPAREN expr_list RPAREN ignore;
block_stmt: BEGIN ignore stmt_list END ignore;
stmt_list: nlAndStmt stmt_list | ;

ignore: NEWLINE+;
// -------------------------- end Syntax structure ----------------------- //
// --------------------------  Lexical structure ----------------------- //
// KeyWord
TRUE: 'true';
FALSE: 'false';
NUMBER: 'number';
BOOL: 'bool';
STRING: 'string';
RETURN: 'return';
VAR: 'var';
DYNAMIC: 'dynamic';
FUNC: 'func';
UNTIL: 'until';
BY: 'by';
BREAK: 'break';
CONTINUE: 'continue';
IF: 'if';
ELSE: 'else';
ELIF: 'elif';
BEGIN: 'begin';
END: 'end';
NOT: 'not';
AND: 'and';
OR: 'or';
FOR: 'for';

// Operators
PLUS: '+';
MINUS: '-';
MULTIPLY: '*';
DIVIDE: '/';
MODULUS: '%';
EQUAL: '=';
ASSIGNINIT: '<-';
NOTEQUAL: '!=';
LESS: '<';
LESSEQUAL: '<=';
GREATER: '>';
GREATEREQUAL: '>=';
CONCAT: '...';
EQUALITY: '==';

// Separators
LPAREN: '(';
RPAREN: ')';
LBRACKET: '[';
RBRACKET: ']';
COMMA: ',';
NEWLINE: [\n]; //LMversion
//NEWLINE: [\r\n]; //HKT

// Identifiers
ID: [a-zA-Z_][a-zA-Z0-9_]*;

// Literal 
NUMBER_LIT: INTP DECP? EXPP?;
fragment INTP: [0-9]+;
fragment DECP: [.] [0-9]*;
fragment EXPP: [eE] [+-]? [0-9]+;
STRING_LIT: ["] ALLOWEDCHAR* ["] {self.text = self.text[1:-1]};
//fragment ALLOWEDCHAR: (~[\\\n"]) | ('\\' [bntrf'\\]) | ['] ["]; //HKT
fragment ALLOWEDCHAR: ~[\r\n\f\\"] | '\\' [bfrnt'\\] | ['] ["]; //LMversion

// NEWLINE COMMENTS WS
COMMENTS: '##' ~[\n\r\f]* -> skip; //LMversion
//COMMENTS: '##' ~[\r\n]* -> skip; //HKT

WS : [ \t\r\f\b]+ -> skip ; // skip spaces, tabs (LMversion)
//WS : [ \t]+ -> skip ; //HKT

// ERROR
ERROR_CHAR: . {raise ErrorToken(self.text)};

//UNCLOSE_STRING: ["] ALLOWEDCHAR* ('\n')? {
//    raise UncloseString(self.text[1:-1] if self.text[-1] == '\n' else self.text[1:])
//};

UNCLOSE_STRING: ["] ALLOWEDCHAR* ('\r\n' | '\n' | EOF) {
    if self.text[-1] == '\n' and self.text[-2] == '\r':
        raise UncloseString(self.text[1:-2])
    elif self.text[-1] == '\n':
        raise UncloseString(self.text[1:-1])
    else:
        raise UncloseString(self.text[1:])
}; //LMversion

ILLEGAL_ESCAPE: ["] ALLOWEDCHAR* ILLEGAL {
    raise IllegalEscape(self.text[1:])
};
//fragment ILLEGAL: '\\' ~[bnftr'\\]; //HKT
fragment ILLEGAL: [\r\f] | '\\' ~[bfrnt'\\];
//!  -------------------------- end Lexical structure ------------------- //