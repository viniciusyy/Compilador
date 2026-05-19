const std = @import("std");

const cli = @import("args.zig");

const token = @import("token.zig");
const ast = @import("ast.zig");
const parser = @import("parser.zig");
const eval = @import("eval.zig");
const codegen = @import("codegen.zig");

const VERSION = "0.1.0";

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;

    const args = try init.minimal.args.toSlice(gpa);
    defer gpa.free(args);

    const config = try cli.configParser(args);

    if (config.help) {
        showHelp();
        std.process.exit(0);
    }

    if (config.version) {
        showVersion();
        std.process.exit(0);
    }

    const generator = codegen.CodeGenerator.init(.{});

    try generator.generate();
}

pub fn showHelp() void {
    const msg =
        \\Uso: comp [opcoes] <arquivo>
        \\
        \\Opcoes:
        \\  -h, --help        Mostra esta ajuda
        \\  -v, --version     Mostra a versao do compilador
        \\
    ;

    std.debug.print("{s}\n", .{msg});
}

pub fn showVersion() void {
    std.debug.print("comp version {s}\n", .{VERSION});
}

test "importacoes" {
    std.testing.refAllDecls(@This());

    _ = token;
    _ = ast;
    _ = parser;
    _ = eval;
    _ = codegen;
}