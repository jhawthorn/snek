#include "cnek.h"

VALUE rb_mCnek;
VALUE rb_cCnekGrid;

static VALUE i_x, i_y;

struct snake_grid {
  unsigned int width;
  unsigned int height;
  VALUE *values;
};

static VALUE allocate_grid(VALUE klass) {
  struct snake_grid *grid;
  VALUE obj = Data_Make_Struct(klass, struct snake_grid, NULL, NULL, grid);

  return obj;
}

static VALUE rb_cnekgrid_initialize(VALUE self, VALUE width, VALUE height) {
  struct snake_grid *grid;
  Data_Get_Struct(self, struct snake_grid, grid);

  grid->width = NUM2UINT(width);
  grid->height = NUM2UINT(height);
  grid->values = xcalloc(grid->width * grid->height, sizeof(VALUE));

  return Qnil;
}

static void grid_bounds_check(struct snake_grid *grid, int x, int y) {
  if (x >= grid->width || y >= grid->height) {
    rb_raise(rb_eArgError, "point out of range");
  }
}

static VALUE rb_cnekgrid_set(VALUE self, VALUE xval, VALUE yval, VALUE value) {
  struct snake_grid *grid;
  Data_Get_Struct(self, struct snake_grid, grid);

  unsigned int x = FIX2INT(xval);
  unsigned int y = FIX2INT(yval);

  grid_bounds_check(grid, x, y);

  grid->values[y * grid->width + x] = value;

  return value;
}

static VALUE rb_cnekgrid_set_all(VALUE self, VALUE points, VALUE value) {
  struct snake_grid *grid;
  Data_Get_Struct(self, struct snake_grid, grid);

  for (unsigned int i = 0; i < RARRAY_LEN(points); i++) {
    VALUE point = RARRAY_AREF(points, i);
    VALUE x = rb_funcall(point, i_x, 0);
    VALUE y = rb_funcall(point, i_y, 0);
    rb_cnekgrid_set(self, x, y, value);
  }
}

static VALUE rb_cnekgrid_at(VALUE self, VALUE xval, VALUE yval) {
  struct snake_grid *grid;
  Data_Get_Struct(self, struct snake_grid, grid);

  unsigned int x = FIX2INT(xval);
  unsigned int y = FIX2INT(yval);

  grid_bounds_check(grid, x, y);

  return grid->values[y * grid->width + x];
}

void
Init_cnek(void)
{
  i_x = rb_intern("x");
  i_y = rb_intern("y");

  rb_mCnek = rb_define_module("Cnek");
  //rb_define_singleton_method(mod, "calculate_bfs", rb_cnek_calculate_bfs, 1);

  rb_cCnekGrid = rb_define_class_under(rb_mCnek, "Grid", rb_cObject);
  rb_define_alloc_func(rb_cCnekGrid, allocate_grid);
  rb_define_method(rb_cCnekGrid, "initialize", rb_cnekgrid_initialize, 2);
  rb_define_method(rb_cCnekGrid, "set_all", rb_cnekgrid_set_all, 2);
  rb_define_method(rb_cCnekGrid, "at", rb_cnekgrid_at, 2);
  rb_define_method(rb_cCnekGrid, "set", rb_cnekgrid_set, 3);
}
