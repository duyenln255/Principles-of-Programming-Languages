# Question 3 Correct
# Given the grammar of MP as follows:
# program: vardecls
# EOF;
# vardecls: vardecl vardecltail;
# vardecltail: vardecl vardecltail |;
# vardecl: mptype ids ';';
# mptype: INTTYPE | FLOATTYPE;
# ids: ID ',' ids | ID;
# INTTYPE: 'int';
# FLOATTYPE: 'float';
# ID: [a - z] +;
# Please copy the following class into your answer and modify the bodies of its methods to count the internal nodes in the parse tree?

class NonTerminalCount(MPVisitor):
    def visitProgram(self, ctx: MPParser.ProgramContext):
        return self.visit(ctx.vardecls()) + 1

    def visitVardecls(self, ctx: MPParser.VardeclsContext):
        count = 0
        if ctx.vardecl() is not None:
            count += 1 + self.visit(ctx.vardecl()) + self.visit(ctx.vardecltail())
        return count

    def visitVardecltail(self, ctx: MPParser.VardecltailContext):
        count = 0
        if ctx.vardecl() is not None:
            count += self.visit(ctx.vardecl()) + self.visit(ctx.vardecltail())
        return count

    def visitVardecl(self, ctx: MPParser.VardeclContext):
        return 3 + self.visit(ctx.ids())

    def visitMptype(self, ctx: MPParser.MptypeContext):
        return 1

    def visitIds(self, ctx: MPParser.IdsContext):
        count = 0
        if ctx.ID() is not None:
            count += 1
        if ctx.ids() is not None:
            count += self.visit(ctx.ids())
        return count


# class Height(MPVisitor):
#     def visitProgram(self, ctx: MPParser.ProgramContext):
#         # Chiều cao của chương trình là chiều cao của vardecls cộng thêm 1 (cho nút gốc)
#         return 1 + self.visit(ctx.vardecls())
#
#     def visitVardecls(self, ctx: MPParser.VardeclsContext):
#         # Chiều cao của vardecls là chiều cao của vardecl cộng thêm 1 (cho nút gốc)
#         # và chiều cao của vardecltail
#         return 1 + max(self.visit(ctx.vardecl()), self.visit(ctx.vardecltail()))
#
#     def visitVardecltail(self, ctx: MPParser.VardecltailContext):
#         if ctx.vardecl():
#             # Nếu có vardecl, chiều cao của vardecltail là chiều cao của vardecl
#             # cộng thêm 1 (cho nút gốc) và chiều cao của vardecltail
#             return 1 + max(self.visit(ctx.vardecl()), self.visit(ctx.vardecltail()))
#         else:
#             # Nếu không có vardecl, chiều cao của vardecltail là 0
#             return 0
#
#     def visitVardecl(self, ctx: MPParser.VardeclContext):
#         # Chiều cao của vardecl là chiều cao của mptype cộng thêm 1 (cho nút gốc)
#         # và chiều cao của ids
#         return 1 + max(self.visit(ctx.mptype()), self.visit(ctx.ids()))
#
#     def visitMptype(self, ctx: MPParser.MptypeContext):
#         # Chiều cao của mptype là 2, vì chỉ có một nút là INTTYPE hoặc FLOATTYPE
#         return 2
#
#     def visitIds(self, ctx: MPParser.IdsContext):
#         if ctx.ids():
#             # Nếu có ids, chiều cao của ids là chiều cao của ids cộng thêm 1 (cho dấu phẩy)
#             return 1 + self.visit(ctx.ids())
#         else:
#             # Nếu không có ids, chiều cao của ids là 2 (cho ID và dấu phẩy)
#             return 2
# class NonTerminalCount(MPVisitor):
#     def visitProgram(self, ctx: MPParser.ProgramContext):
#         return None
#
#     def visitVardecls(self, ctx: MPParser.VardeclsContext):
#         return None
#
#     def visitVardecltail(self, ctx: MPParser.VardecltailContext):
#         return None
#
#     def visitVardecl(self, ctx: MPParser.VardeclContext):
#         return None
#
#     def visitMptype(self, ctx: MPParser.MptypeContext):
#         return None
#
#     def visitIds(self, ctx: MPParser.IdsContext):
#         return None
