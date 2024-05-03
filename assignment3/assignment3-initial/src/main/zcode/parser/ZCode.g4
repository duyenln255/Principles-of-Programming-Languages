grammar ZCode;

@lexer::header {
from lexererr import *
}

options {
	language=Python3;
}
// //! --------------------------  Lexical structure ----------------------- //

// declared
program: NEWLINE* list_declared EOF;
list_declared:  declared list_declared |  declared;
declared: function | variables ignore;

// Variable declare
variables: implicit_var | keyword_var | implicit_dynamic; 
//TODO implicit_var, keyword_var , implicit_dynamic
implicit_var: VAR ID ASSIGNINIT expression;
keyword_var: (primitive_decl | array_decl) (ASSIGNINIT expression)?;
implicit_dynamic: dynamic_decl (ASSIGNINIT expression)?;

// type:
primitive_type: NUMBER | BOOL | STRING ;
primitive_decl: primitive_type ID;
array_decl: primitive_type ID LSB list_NUMBER_LIT RSB;
dynamic_decl: DYNAMIC ID;

// function declare
function: FUNC ID LP (prameters_list)? RP (ignore? return_statement | ignore? block_statement | ignore);
//TODO prameters_list
prameters_list: prameter CM prameters_list | prameter; 
prameter: primitive_decl | array_decl;

//TODO Expression, Value phần trước
expression: expression1 STR_CONCAT expression1 | expression1;
expression1: expression2 (EQUAL | STR_EQ | NOT_EQUAL | LT | GT | LE | GE) expression2 | expression2;
expression2: expression2 (AND | OR) expression3 | expression3;
expression3: expression3 (ADD | SUB) expression4 | expression4;
expression4: expression4 (MUL | DIV | MOD) expression5 | expression5;
expression5: (NOT) expression5 | expression6;
expression6: (SUB | ADD) expression6 | expression7;
expression7: ID (LP list_expression RP)? LSB (params) RSB | expression8;//expression7: expression8 LSB (params) RSB | expression8; 

expression8: ID | literal | LP expression RP | ID LP list_expression RP;
// function passing trong expression cuối cùng

//! Value
literal: NUMBER_LIT | STRING_LIT | TRUE | FALSE | array_literal;
//array_literal: LSB (list_literal)? RSB;
array_literal: LSB (params) RSB; // array_literal: LSB (list_expression) RSB;
//LSB (params) RSB: LSB (params) RSB;
//LSB (params) RSBs: LSB (params) RSB LSB (params) RSBs | LSB (params) RSB;

// list các tham số 
//list_literal: literal CM list_literal | literal;

list_expression: params | ; // list này có thể rỗng
params: expression CM params | expression; //params thì không -> làm param của index trong mảng

list_NUMBER_LIT: NUMBER_LIT CM list_NUMBER_LIT | NUMBER_LIT; //cần thay NUMBER_LIT bằng INTLIT không?

//TODO Statements phần này hãy hiện thực các statement sau
statement: declaration_statement | assignment_statement 
            | if_statement | for_statement 
            | break_statement | continue_statement 
            | return_statement  | call_statement | block_statement;
declaration_statement: variables ignore;
assignment_statement: (ID (LSB (params) RSB)?) ASSIGNINIT expression ignore;
if_statement: IF LP expression RP (ignore? statement) list_elif (ELSE (ignore? statement))?;
list_elif: ELIF LP expression RP (ignore? statement) list_elif | ;
for_statement: FOR ID UNTIL expression BY expression (ignore? statement);
break_statement: BREAK ignore;
continue_statement: CONTINUE ignore;
return_statement: RETURN (expression)? ignore;
call_statement: ID LP list_expression RP ignore;
block_statement: BEGIN (ignore statement_inBLK) END ignore; 
statement_inBLK: statement_temp | ; //statement_list
statement_temp: may_ignore_statement statement_temp | may_ignore_statement; 
may_ignore_statement: ignore? statement | ignore;

// kí tự bỏ qua
ignore: NEWLINE+;


//! --------------------------  Lexical structure ----------------------- //
// TODO   Lexical
// TODO KeyWord
TRUE: 'true';
FALSE: 'false';
NUMBER: 'number';
BOOL: 'bool';
STRING: 'string'; 
RETURN: 'return';
VAR: 'var'; 
DYNAMIC: 'dynamic';
FUNC: 'func'; 
FOR: 'for';
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


// TODO Operators fragment
/*+ - * / %  = <- != < <= >
>= ... == */
ADD: '+';
SUB: '-';
MUL: '*';
DIV: '/';
MOD: '%';
EQUAL: '=';
NOT_EQUAL: '!=';
LT: '<';
GT: '>';
LE: '<=';
GE: '>=';

STR_EQ: '==';
STR_CONCAT: '...';
ASSIGNINIT: '<-';

// TODO Separators
/*( ) [ ] , */
LSB: '[';
RSB: ']';
LP: '(';
RP: ')';
CM: ',';

// TODO Identifiers
ID: [a-zA-Z_][a-zA-Z0-9_]*;

// TODO Literal 
//! STRING_LIT nhớ dùng python bỏ đi " " đầu và cuối và NUMBER_LIT
//BOOLLIT: 'true' | 'false'; //vì ở trên keyword khai báo true false rồi
NUMBER_LIT: DIGITS OPT_FRAC OPT_EXP;
fragment DIGIT: [0-9];
fragment DIGITS: DIGIT+;
fragment OPT_FRAC: ('.' DIGIT*)?;
fragment OPT_EXP: ([Ee] [+-]? DIGITS)?;
// hỗ trợ cho array index
INTLIT: DIGIT+;

STRING_LIT: '"' STR_CHAR* '"' {
    self.text = self.text[1:-1] };
fragment STR_CHAR: ~[\r\n\\"] | ESC_SEQ;
fragment ESC_SEQ: '\\' [bfrnt'\\] | '\'"';
fragment ESC_ILLEGAL: [\r] | '\\' ~[bfrnt'\\];

// NEWLINE COMMENTS WS
NEWLINE: [\n]; // 
COMMENTS: '##' ~[\n\r]* -> skip; // Comments
WS : [ \f\b\t\r]+ -> skip ; // skip spaces, tabs

// TODO ERROR
ERROR_CHAR: . {raise ErrorToken(self.text)};

UNCLOSE_STRING: '"' STR_CHAR* ('\r\n' | '\n' | EOF) {
    if(len(self.text) >= 2 and self.text[-1] == '\n' and self.text[-2] == '\r'):
        raise UncloseString(self.text[1:-2])
    elif (self.text[-1] == '\n'):
        raise UncloseString(self.text[1:-1])
    else:
        raise UncloseString(self.text[1:])
};

ILLEGAL_ESCAPE: '"' STR_CHAR* ESC_ILLEGAL {
    raise IllegalEscape(self.text[1:])
};


//!  -------------------------- end Lexical structure ------------------- //
// // grammar ZCode;

// // @lexer::header {
// // from lexererr import *
// // }

// // options {
// // 	language=Python3;
// // }

// // program: NUMBER IDENTIFIER EOF;

// // NUMBER: 'number';

// // IDENTIFIER: [a-z] [a-z0-9]*;

// // WS : [ \t\r\n]+ -> skip ; // skip spaces, tabs, newlines
// // ERROR_CHAR: . {raise ErrorToken(self.text)};
// // UNCLOSE_STRING: .;
// // ILLEGAL_ESCAPE: .;
// /////////////////////////////////////////////////////////////////////
// grammar ZCode;

// @lexer::header {
// from lexererr import *
// }

// options {
// 	language=Python3;
// }

// // --------------------------  Syntax structure ----------------------- //

// // declared program
// //program: (ignore | decl)+ EOF;
// //decl: function | variables;
// program: NEWLINE* list_declared EOF;
// list_declared:  declared list_declared |  declared;
// declared: function | variables ignore;

// //declared variable
// variables: implicit_var | keyword_var | implicit_dynamic;
// implicit_var: VAR ID ASSIGNINIT expr;
// //keyword_var: typ ID (LBRACKET list_numberlit RBRACKET)? (ASSIGNINIT expr)?;
// keyword_var: 
//       typ ID
//     | typ ID (LBRACKET list_numberlit RBRACKET)
//     | typ ID (ASSIGNINIT expr)
//     | typ ID (LBRACKET list_numberlit RBRACKET) (ASSIGNINIT expr);
// list_numberlit: NUMBER_LIT number_lit_prime | ;
// number_lit_prime: COMMA NUMBER_LIT number_lit_prime | ;
// //list_numberlit: NUMBER_LIT COMMA list_numberlit | NUMBER_LIT;
// typ: BOOL | NUMBER | STRING;
// //implicit_dynamic: DYNAMIC ID (ASSIGNINIT expr)?;
// implicit_dynamic: 
//       DYNAMIC ID
//     | DYNAMIC ID (ASSIGNINIT expr);

// // declared function
// //function: FUNC ID LPAREN prameters_list RPAREN (ignore? return_stmt | ignore? block_stmt | ignore);
// function: 
//       FUNC ID LPAREN prameters_list RPAREN (return_stmt)
//     | FUNC ID LPAREN prameters_list RPAREN (ignore return_stmt)
//     | FUNC ID LPAREN prameters_list RPAREN (block_stmt)
//     | FUNC ID LPAREN prameters_list RPAREN (ignore block_stmt)
//     | FUNC ID LPAREN prameters_list RPAREN (ignore);
// prameters_list: prameter prameterprime |;
// prameterprime: COMMA prameter prameterprime|;
// //prameter: typ ID (LBRACKET list_numberlit RBRACKET)?;
// prameter: 
//       typ ID
//     | typ ID (LBRACKET list_numberlit RBRACKET);


// // expression
// expr: expr0;
// expr0: expr1 CONCAT expr1 | expr1;
// expr1: expr2 
//     (EQUAL| EQUALITY | NOTEQUAL | LESS | GREATER | LESSEQUAL | GREATEREQUAL) 
//     expr2| expr2;
// expr2: expr2 (AND|OR) expr3 | expr3;
// expr3: expr3 (PLUS|MINUS) expr4 | expr4;
// expr4: expr4 (MULTIPLY|DIVIDE|MODULUS) expr5 | expr5;
// expr5: NOT expr5 | expr6;
// expr6: (PLUS | MINUS) expr6 | expr7;

// expr7: indexOp | expr8;
// expr8: ID | literal | functionCall | subExpr;
// functionCall: ID LPAREN expr_list RPAREN;
// expr_list: expr exprprime |;
// exprprime: COMMA expr exprprime |;
// indexOp: (ID | functionCall) LBRACKET op_idx RBRACKET;
// //op_idx: expr COMMA op_idx | expr;
// op_idx: arrElem COMMA op_idx | arrElem;
// arrElem: expr | array_literal;
// subExpr:LPAREN expr RPAREN;

// // Value (Literals)
// literal: NUMBER_LIT | STRING_LIT | TRUE | FALSE | array_literal;
// array_literal: LBRACKET op_idx RBRACKET;

// //  Statements
// stmt: declaration_stmt | assignment_stmt 
//             | if_stmt | for_stmt 
//             | break_stmt | continue_stmt 
//             | return_stmt  | call_stmt | block_stmt;
// declaration_stmt: variables ignore;
// assignment_stmt : lhs ASSIGNINIT expr ignore;
// //lhs: ID (indexp)?;
// lhs: 
//       ID
//     | ID (indexp);
// indexp: LBRACKET indexlist RBRACKET;
// indexlist: expr COMMA indexlist | expr;


// //if_stmt: IF ifcondition ignore? stmt (ELIF ifcondition ignore? stmt)* (ELSE ignore? stmt)?;
// if_stmt: IF ifPart elifParts elsePart;
// ifPart: ifcondition nlAndStmt;
// elifParts: elifpart elifParts |;
// elifpart: ELIF ifcondition nlAndStmt;
// nlAndStmt: stmt | ignore stmt;
// elsePart: ELSE nlAndStmt | ;
// ifcondition: LPAREN expr RPAREN;
// for_stmt: FOR ID UNTIL expr BY expr nlAndStmt ignore?;

// break_stmt: BREAK ignore;
// continue_stmt: CONTINUE ignore;
// return_stmt: RETURN expr? ignore;
// call_stmt: ID LPAREN expr_list RPAREN ignore;
// block_stmt: BEGIN ignore stmt_list END ignore;
// stmt_list: nlAndStmt stmt_list | ;

// ignore: NEWLINE+;
// // -------------------------- end Syntax structure ----------------------- //
// // --------------------------  Lexical structure ----------------------- //
// // KeyWord
// TRUE: 'true';
// FALSE: 'false';
// NUMBER: 'number';
// BOOL: 'bool';
// STRING: 'string';
// RETURN: 'return';
// VAR: 'var';
// DYNAMIC: 'dynamic';
// FUNC: 'func';
// UNTIL: 'until';
// BY: 'by';
// BREAK: 'break';
// CONTINUE: 'continue';
// IF: 'if';
// ELSE: 'else';
// ELIF: 'elif';
// BEGIN: 'begin';
// END: 'end';
// NOT: 'not';
// AND: 'and';
// OR: 'or';
// FOR: 'for';

// // Operators
// PLUS: '+';
// MINUS: '-';
// MULTIPLY: '*';
// DIVIDE: '/';
// MODULUS: '%';
// EQUAL: '=';
// ASSIGNINIT: '<-';
// NOTEQUAL: '!=';
// LESS: '<';
// LESSEQUAL: '<=';
// GREATER: '>';
// GREATEREQUAL: '>=';
// CONCAT: '...';
// EQUALITY: '==';

// // Separators
// LPAREN: '(';
// RPAREN: ')';
// LBRACKET: '[';
// RBRACKET: ']';
// COMMA: ',';
// NEWLINE: [\n]; //LMversion
// //NEWLINE: [\r\n]; //HKT

// // Identifiers
// ID: [a-zA-Z_][a-zA-Z0-9_]*;

// // Literal 
// NUMBER_LIT: INTP DECP? EXPP?;
// fragment INTP: [0-9]+;
// fragment DECP: [.] [0-9]*;
// fragment EXPP: [eE] [+-]? [0-9]+;
// STRING_LIT: ["] ALLOWEDCHAR* ["] {self.text = self.text[1:-1]};
// //fragment ALLOWEDCHAR: (~[\\\n"]) | ('\\' [bntrf'\\]) | ['] ["]; //HKT
// fragment ALLOWEDCHAR: ~[\r\n\f\\"] | '\\' [bfrnt'\\] | ['] ["]; //LMversion

// // NEWLINE COMMENTS WS
// COMMENTS: '##' ~[\n\r\f]* -> skip; //LMversion
// //COMMENTS: '##' ~[\r\n]* -> skip; //HKT

// WS : [ \t\r\f\b]+ -> skip ; // skip spaces, tabs (LMversion)
// //WS : [ \t]+ -> skip ; //HKT

// // ERROR
// ERROR_CHAR: . {raise ErrorToken(self.text)};

// //UNCLOSE_STRING: ["] ALLOWEDCHAR* ('\n')? {
// //    raise UncloseString(self.text[1:-1] if self.text[-1] == '\n' else self.text[1:])
// //};

// UNCLOSE_STRING: ["] ALLOWEDCHAR* ('\r\n' | '\n' | EOF) {
//     if self.text[-1] == '\n' and self.text[-2] == '\r':
//         raise UncloseString(self.text[1:-2])
//     elif self.text[-1] == '\n':
//         raise UncloseString(self.text[1:-1])
//     else:
//         raise UncloseString(self.text[1:])
// }; //LMversion

// ILLEGAL_ESCAPE: ["] ALLOWEDCHAR* ILLEGAL {
//     raise IllegalEscape(self.text[1:])
// };
// //fragment ILLEGAL: '\\' ~[bnftr'\\]; //HKT
// fragment ILLEGAL: [\r\f] | '\\' ~[bfrnt'\\];
// //!  -------------------------- end Lexical structure ------------------- //