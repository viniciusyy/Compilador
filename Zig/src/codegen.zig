const std = @import("std");

pub const Target = enum {
    zig,
    c,
    bytecode,
};

pub const Config = struct {
    target: Target = .c,
};

pub const CodegenError = error{
    UnsupportedTarget,
    EmptyProgram,
};

pub const CodeGenerator = struct {
    config: Config,

    pub fn init(config: Config) CodeGenerator {
        return .{
            .config = config,
        };
    }

    pub fn generate(self: *const CodeGenerator) !void {
        _ = self;

        std.debug.print("Codegen ainda não implementado.\n", .{});
    }
};

test "codegen básico" {
    const generator = CodeGenerator.init(.{});

    try generator.generate();
}