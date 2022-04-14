module frame_buffer;

import core.stdc.stdlib;
import color;

class FrameBuffer {
   uint bpp = 4;

   uint width;
   uint height;
   uint pixels;
   size_t pitch;
   ubyte *c_buf;
   Color[][] buf;

   this(uint width, uint height)
   {
      this.width = width;
      this.height = height;
      this.pixels = this.width * this.height;
      this.pitch = this.bpp * this.width * ubyte.sizeof;
      this.c_buf = cast(ubyte*)malloc(this.pixels * this.bpp * ubyte.sizeof);
      this.buf = new Color[][](this.height, this.width);
   }

   ~this()
   {
      free(c_buf);
   }

   ubyte *c_frame_buffer() {
      redraw();
      return this.c_buf;
   }

   void draw_rect(int x, int y, int w, int h, Color color) {
      for (int i = y; i < y + h; i++) {
         for (int j = x; j < x + w; j++) {
            this.buf[i][j] = color;
         }
      }
   }

   void redraw() {
      for (int y = 0; y < this.height; y++) {
         for (int x = 0; x < this.width; x++) {
            Color pixel = this.buf[y][x];
            uint pixel_index = y * this.width + x;
            uint base_index = pixel_index * this.bpp;

            // writeln("Pixel ", pixel_index, " from ", x, " - ", y, " with Offset(", base_index, ")", " with: Color(", pixel.a, ", ", pixel.r, ", ", pixel.g, ", ", pixel.b, ")");
            // Note: Order is reversed I don't really get why ?
            c_buf[base_index .. base_index + this.bpp] = [pixel.b, pixel.g, pixel.r, pixel.a];
         }
      }
   }
}
