pub const c = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("SDL2/SDL_ttf.h");
});

const constants = @import("helpers").constants;
const std = @import("std");
const common = @import("common.zig");
const SDL_WINDOW_HEIGHT: u32 = 1000;
const SDL_WINDOW_WIDTH: u32 = 1500;

const ReadEventError = error{
    QuitWasPressed,
};

pub const GameDisplay = struct {
    win: *c.SDL_Window,
    font: *c.TTF_Font,
    font_color: c.SDL_Color,
    renderer: *c.SDL_Renderer,
    texture_buffer: [255]?*c.SDL_Texture,
    _input_buffer: [256]bool,

    pub fn init() !GameDisplay {
        _ = c.SDL_Init(c.SDL_VIDEO_DRIVER_COCOA);
        _ = c.TTF_Init();

        const font: *c.TTF_Font = c.TTF_OpenFont("assets/fonts/Consolas.ttf", 50) orelse sdl_panic("Loading font");
        const font_color: c.SDL_Color = .{ .r = 255, .g = 255, .b = 255 };
        const win = c.SDL_CreateWindow("Game", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, SDL_WINDOW_WIDTH, SDL_WINDOW_HEIGHT, 0) orelse sdl_panic("Creating window");
        const renderer = c.SDL_CreateRenderer(win, 0, c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC) orelse sdl_panic("Creating renderer");
        var texture_buffer: [255]?*c.SDL_Texture = .{undefined} ** 255;

        for (0..255) |char| {
            const surface = c.TTF_RenderGlyph_Solid(font, @intCast(char), font_color);

            const texture = c.SDL_CreateTextureFromSurface(renderer, surface);
            if (texture == null) {
                std.debug.print("Could not create texture for character '{}'", .{char});
                texture_buffer[char] = null;
            } else {
                texture_buffer[char] = texture;
            }
        }
        return GameDisplay{
            .win = win,
            .font_color = font_color,
            .font = font,
            .renderer = renderer,
            .texture_buffer = texture_buffer,
            ._input_buffer = .{false} ** 256,
        };
    }

    pub fn display_buffer(self: *GameDisplay, render_buffer: *common.RenderBuffer) !void {
        if (c.SDL_RenderClear(self.renderer) != 0) {
            sdl_panic("Clearing renderer");
        }
        const char_w = SDL_WINDOW_WIDTH / constants.WINDOW_WIDTH;
        const char_h = SDL_WINDOW_HEIGHT / constants.WINDOW_HEIGHT;

        for (render_buffer.chars, 0..) |char, index| {
            const texture = self.texture_buffer[char];
            if (texture == null) {
                std.debug.print("Could not display charactr '{}'\n", .{char});
                continue;
            }

            const row = index / constants.WINDOW_WIDTH;
            const column = index % constants.WINDOW_WIDTH;
            const x = column * char_w;
            const y = row * char_h;

            const dest_rect: c.SDL_Rect = .{ .x = @intCast(x), .y = @intCast(y), .w = @intCast(char_w), .h = @intCast(char_h) }; //create a rect
            const angle: f32 = render_buffer.rotation[index].to_angle();

            const center = c.SDL_Point{ .x = char_w / 2, .y = char_h / 2 };
            if (c.SDL_RenderCopyEx(self.renderer, texture, null, &dest_rect, angle, &center, 0) != 0) {
                sdl_panic("Could not render");
            }
        }

        c.SDL_RenderPresent(self.renderer);
    }

    pub fn read_events(self: *GameDisplay) ReadEventError!*[256]bool {
        // Reads all events during this frame to the given buffer.
        // Returns the number of events read.
        // Returns an error if Quit was pressed.

        var event: c.SDL_Event = undefined;

        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    return ReadEventError.QuitWasPressed;
                },
                c.SDL_KEYDOWN => {
                    if (event.key.keysym.scancode == c.SDL_SCANCODE_ESCAPE) {
                        return ReadEventError.QuitWasPressed;
                    }
                    self._input_buffer[event.key.keysym.scancode] = true;
                },
                c.SDL_KEYUP => {
                    self._input_buffer[event.key.keysym.scancode] = false;
                },
                else => {},
            }
        }
        return &self._input_buffer;
    }
};

fn ttf_panic(base_msg: []const u8) noreturn {
    std.debug.print("TTF panic detected.\n", .{});
    const message = c.TTF_GetError() orelse @panic("Unknown error in TTF.");

    var ptr: u32 = 0;
    char_loop: while (true) {
        const char = message[ptr];
        if (char == 0) {
            break :char_loop;
        }
        ptr += 1;
    }
    var zig_slice: []const u8 = undefined;
    zig_slice.len = ptr;
    zig_slice.ptr = message;
    std.debug.print("{}: {any}", .{ ptr, message });

    var full_msg: [256]u8 = undefined;
    join_strs(base_msg, zig_slice, &full_msg);

    @panic(&full_msg);
}
fn sdl_panic(base_msg: []const u8) noreturn {
    std.debug.print("SDL panic detected.\n", .{});
    const message = c.SDL_GetError() orelse @panic("Unknown error in SDL.");

    var ptr: u32 = 0;
    char_loop: while (true) {
        const char = message[ptr];
        if (char == 0) {
            break :char_loop;
        }
        ptr += 1;
    }
    var zig_slice: []const u8 = undefined;
    zig_slice.len = ptr;
    zig_slice.ptr = message;

    var full_msg: [256]u8 = undefined;
    join_strs(base_msg, zig_slice, &full_msg);

    @panic(&full_msg);
}

fn join_strs(s1: []const u8, s2: []const u8, buf: []u8) void {
    for (s1, 0..) |char, index| {
        buf[index] = char;
    }
    for (s2, 0..) |char, index| {
        buf[s1.len + index] = char;
    }
}
