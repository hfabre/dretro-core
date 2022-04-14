module color;

struct Color {
   ubyte a = 0;
   ubyte r = 0;
   ubyte g = 0;
   ubyte b = 0;
}

static Color white = {
   r: ubyte.max,
   g: ubyte.max,
   b: ubyte.max
};

static Color black = {};

static Color grey = {
   r: 127,
   g: 127,
   b: 127
};

static Color blue = {
   b: ubyte.max
};

static Color red = {
   r: ubyte.max
};

static Color green = {
   g: ubyte.max
};
