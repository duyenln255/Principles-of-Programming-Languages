# Question 4 Correct
# Given the grammar of MP as follows:
# program: vardecls EOF;
# vardecls: vardecl vardecltail;
# vardecltail: vardecl vardecltail | ;
# vardecl: mptype ids ';' ;
# mptype: INTTYPE | FLOATTYPE;
# ids: ID ',' ids | ID;
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

class ASTGeneration(MPVisitor):
    def visitProgram(self,ctx:MPParser.ProgramContext):
        vardecls = self.visit(ctx.vardecls())
        return Program(vardecls)
    def visitVardecls(self,ctx:MPParser.VardeclsContext):
        vardecl = self.visit(ctx.vardecl())
        vardecltail = self.visit(ctx.vardecltail())
        if vardecltail is None:  return vardecl
        return vardecl + vardecltail
    def visitVardecltail(self,ctx:MPParser.VardecltailContext):
        if ctx.vardecltail() is None:
            return None
        vardecl = self.visit(ctx.vardecl())
        vardecltail = self.visit(ctx.vardecltail())
        if vardecltail is None:  return vardecl
        return vardecl + vardecltail
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
        if ctx.ids() is None:
            return [Id(ctx.ID().getText())]
        return [Id(ctx.ID().getText())] + self.visit(ctx.ids())
# class ASTGeneration(MPVisitor):
#     def visitProgram(self,ctx:MPParser.ProgramContext):
#         return None
#     def visitVardecls(self,ctx:MPParser.VardeclsContext):
#         return None
#     def visitVardecltail(self,ctx:MPParser.VardecltailContext):
#         return None
#     def visitVardecl(self,ctx:MPParser.VardeclContext):
#         return None
#     def visitMptype(self,ctx:MPParser.MptypeContext):
#         return None
#     def visitIds(self,ctx:MPParser.IdsContext):
#         return None