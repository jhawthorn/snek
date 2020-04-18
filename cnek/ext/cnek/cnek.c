#include "cnek.h"

VALUE rb_mCnek;

void
Init_cnek(void)
{
  rb_mCnek = rb_define_module("Cnek");
}
