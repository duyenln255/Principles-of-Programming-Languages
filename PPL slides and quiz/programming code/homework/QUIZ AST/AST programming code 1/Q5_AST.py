# Question 5 Correct
# Given the grammar of MP as follows:
# program: vardecl+ EOF;
# vardecl: mptype ids ';' ;
# mptype: INTTYPE | FLOATTYPE;
# ids: ID (',' ID)*;
# INTTYPE: 'int';
# FLOATTYPE: 'float';
# ID: [a-z]+ ;
# and AST classes as follows:
# class Program:#decl:list(VarDecl)
# class Type(ABC): pass
# class IntType(Type): pass
# class FloatType(Type): pass
# class VarDecl: #variable:Id; varType: Type
# class Id: #name:str
# Please copy the following class into your answer and modify the bodies of its methods to generate the AST of a MP input?
# class ASTGeneration(MPVisitor):
#     def visitProgram(self,ctx:MPParser.ProgramContext):
#         return None
#     def visitVardecl(self,ctx:MPParser.VardeclContext):
#         return None
#     def visitMptype(self,ctx:MPParser.MptypeContext):
#         return None
#     def visitIds(self,ctx:MPParser.IdsContext):
#         return None
# Answer:(penalty regime: 0 %)
class ASTGeneration(MPVisitor):
    def visitProgram(self,ctx:MPParser.ProgramContext):
        body = []
        for decl in ctx.vardecl():
            body = body + self.visit(decl)
        return Program(body)
    def visitVardecl(self,ctx:MPParser.VardeclContext):
        typ = self.visit(ctx.mptype())
        ids = self.visit(ctx.ids())
        list_var = []
        for i in ids:
            list_var.append(VarDecl(i,typ))
        return list_var
    def visitMptype(self,ctx:MPParser.MptypeContext):
        if ctx.INTTYPE():
            return IntType()
        return FloatType()
    def visitIds(self,ctx:MPParser.IdsContext):
        list_id=ctx.ID()
        result = []
        for i in list_id:
            result.append(Id(i.getText()))
        return result
