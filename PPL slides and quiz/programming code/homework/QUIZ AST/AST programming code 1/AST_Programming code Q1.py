# #Question 1
# Correct
# Marked out of 1.00
#  Flag question
# Question text
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
# Please copy the following class into your answer and modify the bodies of its methods to count the terminal nodes in the parse tree? Your code starts at line 10.

class TerminalCount(MPVisitor):
    def visitProgram(self, ctx: MPParser.ProgramContext):
        return 1 + self.visit(ctx.vardecls())

    def visitVardecls(self, ctx: MPParser.VardeclsContext):
        return self.visit(ctx.vardecl()) + self.visit(ctx.vardecltail())

    def visitVardecltail(self, ctx: MPParser.VardecltailContext):
        return self.visit(ctx.vardecl()) + self.visit(ctx.vardecltail()) if ctx.vardecl() else 0

    def visitVardecl(self, ctx: MPParser.VardeclContext):
        return 1 + self.visit(ctx.mptype()) + self.visit(ctx.ids())

    def visitMptype(self, ctx: MPParser.MptypeContext):
        return 1

    def visitIds(self, ctx: MPParser.IdsContext):
        return 2 + self.visit(ctx.ids()) if ctx.ids() else 1

    # class TerminalCount(MPVisitor):
    #     def visitProgram(self, ctx: MPParser.ProgramContext):
    #         # Đếm nút terminal của vardecls và thêm 1 cho chính nó (EOF)
    #         return 1 + self.visit(ctx.vardecls())
    #
    #     def visitVardecls(self, ctx: MPParser.VardeclsContext):
    #         # Đếm nút terminal của vardecl và vardecltail
    #         return self.visit(ctx.vardecl()) + self.visit(ctx.vardecltail())
    #
    #     def visitVardecltail(self, ctx: MPParser.VardecltailContext):
    #         # Đếm nút terminal của vardecltail nếu có vardecl, nếu không trả về 0
    #         return self.visit(ctx.vardecl()) + self.visit(ctx.vardecltail()) if ctx.vardecl() else 0
    #
    #     def visitVardecl(self, ctx: MPParser.VardeclContext):
    #         # Đếm nút terminal của mptype và ids, cộng thêm 1 cho chính nó (;)
    #         return 1 + self.visit(ctx.mptype()) + self.visit(ctx.ids())
    #
    #     def visitMptype(self, ctx: MPParser.MptypeContext):
    #         # Mptype là một nút terminal, trả về 1
    #         return 1
    #
    #     def visitIds(self, ctx: MPParser.IdsContext):
    #         # Đếm nút terminal của ids, mỗi ID đều là một nút terminal và có thêm dấu phẩy, nếu có
    #         return 2 + self.visit(ctx.ids()) if ctx.ids() else 1
