#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/test_helper'

class ScssTest < Test::Unit::TestCase
  include ScssTestHelper

  ## One-Line Comments

  def test_one_line_comments
    assert_equal <<CSS, render(<<SCSS)
.foo {
  baz: bang; }
CSS
.foo {// bar: baz;}
  baz: bang; //}
}
SCSS
    assert_equal <<CSS, render(<<SCSS)
.foo bar[val="//"] {
  baz: bang; }
CSS
.foo bar[val="//"] {
  baz: bang; //}
}
SCSS
  end

  ## Script

  def test_variables
    assert_equal <<CSS, render(<<SCSS)
blat {
  a: foo; }
CSS
$var: foo;

blat {a: $var}
SCSS

    assert_equal <<CSS, render(<<SCSS)
foo {
  a: 2;
  b: 6; }
CSS
foo {
  $var: 2;
  $another-var: 4;
  a: $var;
  b: $var + $another-var;}
SCSS
  end

  def test_unicode_variables
    assert_equal <<CSS, render(<<SCSS)
blat {
  a: foo; }
CSS
$vär: foo;

blat {a: $vär}
SCSS
  end

  def test_guard_assign
    assert_equal <<CSS, render(<<SCSS)
foo {
  a: 1; }
CSS
$var: 1;
$var: 2 !default;

foo {a: $var}
SCSS

    assert_equal <<CSS, render(<<SCSS)
foo {
  a: 2; }
CSS
$var: 2 !default;

foo {a: $var}
SCSS
  end

  def test_sass_script
    assert_equal <<CSS, render(<<SCSS)
foo {
  a: 3;
  b: -1;
  c: foobar;
  d: 12px; }
CSS
foo {
  a: 1 + 2;
  b: 1 - 2;
  c: foo + bar;
  d: floor(12.3px); }
SCSS
  end

  def test_debug_directive
    assert_warning "test_debug_directive_inline.scss:2 DEBUG: hello world!" do
      assert_equal <<CSS, render(<<SCSS)
foo {
  a: b; }

bar {
  c: d; }
CSS
foo {a: b}
@debug "hello world!";
bar {c: d}
SCSS
    end
  end

  def test_warn_directive
    expected_warning = <<EXPECTATION
WARNING: this is a warning
        on line 2 of test_warn_directive_inline.scss

WARNING: this is a mixin
        on line 1 of test_warn_directive_inline.scss, in `foo'
        from line 3 of test_warn_directive_inline.scss
EXPECTATION
    assert_warning expected_warning do
      assert_equal <<CSS, render(<<SCSS)
bar {
  c: d; }
CSS
@mixin foo { @warn "this is a mixin";}
@warn "this is a warning";
bar {c: d; @include foo;}
SCSS
    end
  end

  def test_for_directive
    assert_equal <<CSS, render(<<SCSS)
.foo {
  a: 1;
  a: 2;
  a: 3;
  a: 4; }
CSS
.foo {
  @for $var from 1 to 5 {a: $var;}
}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo {
  a: 1;
  a: 2;
  a: 3;
  a: 4;
  a: 5; }
CSS
.foo {
  @for $var from 1 through 5 {a: $var;}
}
SCSS
  end

  def test_if_directive
    assert_equal <<CSS, render(<<SCSS)
foo {
  a: b; }
CSS
@if "foo" == "foo" {foo {a: b}}
@if "foo" != "foo" {bar {a: b}}
SCSS

    assert_equal <<CSS, render(<<SCSS)
bar {
  a: b; }
CSS
@if "foo" != "foo" {foo {a: b}}
@else if "foo" == "foo" {bar {a: b}}
@else if true {baz {a: b}}
SCSS

    assert_equal <<CSS, render(<<SCSS)
bar {
  a: b; }
CSS
@if "foo" != "foo" {foo {a: b}}
@else {bar {a: b}}
SCSS
  end

  def test_while_directive
    assert_equal <<CSS, render(<<SCSS)
.foo {
  a: 1;
  a: 2;
  a: 3;
  a: 4; }
CSS
$i: 1;

.foo {
  @while $i != 5 {
    a: $i;
    $i: $i + 1;
  }
}
SCSS
  end

  def test_css_import_directive
    assert_equal "@import url(foo.css);\n", render('@import "foo.css";')
    assert_equal "@import url(foo.css);\n", render("@import 'foo.css';")
    assert_equal "@import url(foo.css);\n", render('@import url("foo.css");')
    assert_equal "@import url(foo.css);\n", render("@import url('foo.css');")
    assert_equal "@import url(foo.css);\n", render('@import url(foo.css);')
  end

  def test_block_comment_in_script
    assert_equal <<CSS, render(<<SCSS)
foo {
  a: 1bar; }
CSS
foo {a: 1 + /* flang */ bar}
SCSS
  end

  def test_line_comment_in_script
    assert_equal <<CSS, render(<<SCSS)
foo {
  a: 1blang; }
CSS
foo {a: 1 + // flang }
  blang }
SCSS
  end

  ## Nested Rules

  def test_nested_rules
    assert_equal <<CSS, render(<<SCSS)
foo bar {
  a: b; }
CSS
foo {bar {a: b}}
SCSS
    assert_equal <<CSS, render(<<SCSS)
foo bar {
  a: b; }
foo baz {
  b: c; }
CSS
foo {
  bar {a: b}
  baz {b: c}}
SCSS
    assert_equal <<CSS, render(<<SCSS)
foo bar baz {
  a: b; }
foo bang bip {
  a: b; }
CSS
foo {
  bar {baz {a: b}}
  bang {bip {a: b}}}
SCSS
  end

  def test_nested_rules_with_declarations
    assert_equal <<CSS, render(<<SCSS)
foo {
  a: b; }
  foo bar {
    c: d; }
CSS
foo {
  a: b;
  bar {c: d}}
SCSS
    assert_equal <<CSS, render(<<SCSS)
foo {
  a: b; }
  foo bar {
    c: d; }
CSS
foo {
  bar {c: d}
  a: b}
SCSS
    assert_equal <<CSS, render(<<SCSS)
foo {
  ump: nump;
  grump: clump; }
  foo bar {
    blat: bang;
    habit: rabbit; }
    foo bar baz {
      a: b; }
    foo bar bip {
      c: d; }
  foo bibble bap {
    e: f; }
CSS
foo {
  ump: nump;
  grump: clump;
  bar {
    blat: bang;
    habit: rabbit;
    baz {a: b}
    bip {c: d}}
  bibble {
    bap {e: f}}}
SCSS
  end

  def test_nested_rules_with_fancy_selectors
    assert_equal <<CSS, render(<<SCSS)
foo .bar {
  a: b; }
foo :baz {
  c: d; }
foo bang:bop {
  e: f; }
CSS
foo {
  .bar {a: b}
  :baz {c: d}
  bang:bop {e: f}}
SCSS
  end

  def test_almost_ambiguous_nested_rules_and_declarations
    assert_equal <<CSS, render(<<SCSS)
foo {
  bar: baz bang bop biddle woo look at all these elems; }
  foo bar:baz:bang:bop:biddle:woo:look:at:all:these:pseudoclasses {
    a: b; }
  foo bar:baz bang bop biddle woo look at all these elems {
    a: b; }
CSS
foo {
  bar:baz:bang:bop:biddle:woo:look:at:all:these:pseudoclasses {a: b};
  bar:baz bang bop biddle woo look at all these elems {a: b};
  bar:baz bang bop biddle woo look at all these elems; }
SCSS
  end

  def test_newlines_in_selectors
    assert_equal <<CSS, render(<<SCSS)
foo
bar {
  a: b; }
CSS
foo
bar {a: b}
SCSS

    assert_equal <<CSS, render(<<SCSS)
foo baz,
foo bang,
bar baz,
bar bang {
  a: b; }
CSS
foo,
bar {
  baz,
  bang {a: b}}
SCSS

    assert_equal <<CSS, render(<<SCSS)
foo
bar baz
bang {
  a: b; }
foo
bar bip bop {
  c: d; }
CSS
foo
bar {
  baz
  bang {a: b}

  bip bop {c: d}}
SCSS

    assert_equal <<CSS, render(<<SCSS)
foo bang, foo bip
bop, bar
baz bang, bar
baz bip
bop {
  a: b; }
CSS
foo, bar
baz {
  bang, bip
  bop {a: b}}
SCSS
  end

  def test_parent_selectors
    assert_equal <<CSS, render(<<SCSS)
foo:hover {
  a: b; }
bar foo.baz {
  c: d; }
CSS
foo {
  &:hover {a: b}
  bar &.baz {c: d}}
SCSS
  end

  ## Namespace Properties

  def test_namespace_properties
    assert_equal <<CSS, render(<<SCSS)
foo {
  bar: baz;
  bang-bip: 1px;
  bang-bop: bar; }
CSS
foo {
  bar: baz;
  bang: {
    bip: 1px;
    bop: bar;}}
SCSS
  end

  def test_several_namespace_properties
    assert_equal <<CSS, render(<<SCSS)
foo {
  bar: baz;
  bang-bip: 1px;
  bang-bop: bar;
  buzz-fram: "foo";
  buzz-frum: moo; }
CSS
foo {
  bar: baz;
  bang: {
    bip: 1px;
    bop: bar;}
  buzz: {
    fram: "foo";
    frum: moo;
  }
}
SCSS
  end

  def test_nested_namespace_properties
    assert_equal <<CSS, render(<<SCSS)
foo {
  bar: baz;
  bang-bip: 1px;
  bang-bop: bar;
  bang-blat-baf: bort; }
CSS
foo {
  bar: baz;
  bang: {
    bip: 1px;
    bop: bar;
    blat:{baf:bort}}}
SCSS
  end

  def test_namespace_properties_with_value
    assert_equal <<CSS, render(<<SCSS)
foo {
  bar: baz;
    bar-bip: bop;
    bar-bing: bop; }
CSS
foo {
  bar: baz {
    bip: bop;
    bing: bop; }}
SCSS
  end

  def test_namespace_properties_with_script_value
    assert_equal <<CSS, render(<<SCSS)
foo {
  bar: bazbang;
    bar-bip: bop;
    bar-bing: bop; }
CSS
foo {
  bar: baz + bang {
    bip: bop;
    bing: bop; }}
SCSS
  end

  def test_no_namespace_properties_without_space
    assert_equal <<CSS, render(<<SCSS)
foo bar:baz {
  bip: bop; }
CSS
foo {
  bar:baz {
    bip: bop }}
SCSS
  end

  def test_no_namespace_properties_without_space_even_when_its_unambiguous
    render(<<SCSS)
foo {
  bar:1px {
    bip: bop }}
SCSS
    assert(false, "Expected syntax error")
  rescue Sass::SyntaxError => e
    assert_equal <<MESSAGE, e.message
Invalid CSS: a space is required between a property and its definition
when it has other properties nested beneath it.
MESSAGE
    assert_equal 2, e.sass_line
  end

  ## Mixins

  def test_basic_mixins
    assert_equal <<CSS, render(<<SCSS)
.foo {
  a: b; }
CSS
@mixin foo {
  .foo {a: b}}

@include foo;
SCSS

    assert_equal <<CSS, render(<<SCSS)
bar {
  c: d; }
  bar .foo {
    a: b; }
CSS
@mixin foo {
  .foo {a: b}}

bar {
  @include foo;
  c: d; }
SCSS

    assert_equal <<CSS, render(<<SCSS)
bar {
  a: b;
  c: d; }
CSS
@mixin foo {a: b}

bar {
  @include foo;
  c: d; }
SCSS
  end

  def test_mixins_with_empty_args
    assert_equal <<CSS, render(<<SCSS)
.foo {
  a: b; }
CSS
@mixin foo() {a: b}

.foo {@include foo();}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo {
  a: b; }
CSS
@mixin foo() {a: b}

.foo {@include foo;}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo {
  a: b; }
CSS
@mixin foo {a: b}

.foo {@include foo();}
SCSS
  end

  def test_mixins_with_args
    assert_equal <<CSS, render(<<SCSS)
.foo {
  a: bar; }
CSS
@mixin foo($a) {a: $a}

.foo {@include foo(bar)}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo {
  a: bar;
  b: 12px; }
CSS
@mixin foo($a, $b) {
  a: $a;
  b: $b; }

.foo {@include foo(bar, 12px)}
SCSS
  end

  ## Interpolation

  def test_basic_selector_interpolation
    assert_equal <<CSS, render(<<SCSS)
foo 3 baz {
  a: b; }
CSS
foo \#{1 + 2} baz {a: b}
SCSS
    assert_equal <<CSS, render(<<SCSS)
foo.bar baz {
  a: b; }
CSS
foo\#{".bar"} baz {a: b}
SCSS
    assert_equal <<CSS, render(<<SCSS)
foo.bar baz {
  a: b; }
CSS
\#{"foo"}.bar baz {a: b}
SCSS
  end

  def test_selector_only_interpolation
    assert_equal <<CSS, render(<<SCSS)
foo bar {
  a: b; }
CSS
\#{"foo" + " bar"} {a: b}
SCSS
  end

  def test_selector_interpolation_before_element_name
    assert_equal <<CSS, render(<<SCSS)
foo barbaz {
  a: b; }
CSS
\#{"foo" + " bar"}baz {a: b}
SCSS
  end

  def test_selector_interpolation_in_string
    assert_equal <<CSS, render(<<SCSS)
foo[val="bar foo bar baz"] {
  a: b; }
CSS
foo[val="bar \#{"foo" + " bar"} baz"] {a: b}
SCSS
  end

  def test_selector_interpolation_in_pseudoclass
    assert_equal <<CSS, render(<<SCSS)
foo:nth-child(5n) {
  a: b; }
CSS
foo:nth-child(\#{5 + "n"}) {a: b}
SCSS
  end

  def test_selector_interpolation_at_class_begininng
    assert_equal <<CSS, render(<<SCSS)
.zzz {
  a: b; }
CSS
$zzz: zzz;
.\#{$zzz} { a: b; }
SCSS
  end

  def test_selector_interpolation_at_id_begininng
    assert_equal <<CSS, render(<<SCSS)
#zzz {
  a: b; }
CSS
$zzz: zzz;
#\#{$zzz} { a: b; }
SCSS
  end

  def test_selector_interpolation_at_pseudo_begininng
    assert_equal <<CSS, render(<<SCSS)
:zzz::zzz {
  a: b; }
CSS
$zzz: zzz;
:\#{$zzz}::\#{$zzz} { a: b; }
SCSS
  end

  def test_selector_interpolation_at_attr_beginning
    assert_equal <<CSS, render(<<SCSS)
[zzz=foo] {
  a: b; }
CSS
$zzz: zzz;
[\#{$zzz}=foo] { a: b; }
SCSS
  end

  def test_selector_interpolation_at_dashes
    assert_equal <<CSS, render(<<SCSS)
div {
  -foo-a-b-foo: foo; }
CSS
$a : a;
$b : b;
div { -foo-\#{$a}-\#{$b}-foo: foo }
SCSS
  end

  def test_basic_prop_name_interpolation
    assert_equal <<CSS, render(<<SCSS)
foo {
  barbazbang: blip; }
CSS
foo {bar\#{"baz" + "bang"}: blip}
SCSS
    assert_equal <<CSS, render(<<SCSS)
foo {
  bar3: blip; }
CSS
foo {bar\#{1 + 2}: blip}
SCSS
  end

  def test_prop_name_only_interpolation
    assert_equal <<CSS, render(<<SCSS)
foo {
  bazbang: blip; }
CSS
foo {\#{"baz" + "bang"}: blip}
SCSS
  end

  ## Errors

  def test_mixin_defs_only_at_toplevel
    render <<SCSS
foo {
  @mixin bar {a: b}}
SCSS
    assert(false, "Expected syntax error")
  rescue Sass::SyntaxError => e
    assert_equal "Mixins may only be defined at the root of a document.", e.message
    assert_equal 2, e.sass_line
  end

  def test_imports_only_at_toplevel
    render <<SCSS
foo {
  @import "foo.scss";}
SCSS
    assert(false, "Expected syntax error")
  rescue Sass::SyntaxError => e
    assert_equal "Import directives may only be used at the root of a document.", e.message
    assert_equal 2, e.sass_line
  end

  def test_rules_beneath_properties
    render <<SCSS
foo {
  bar: {
    baz {
      bang: bop }}}
SCSS
    assert(false, "Expected syntax error")
  rescue Sass::SyntaxError => e
    assert_equal 'Illegal nesting: Only properties may be nested beneath properties.', e.message
    assert_equal 3, e.sass_line
  end

  def test_uses_property_exception_with_star_hack
    render <<SCSS
foo {
  *bar:baz [fail]; }
SCSS
    assert(false, "Expected syntax error")
  rescue Sass::SyntaxError => e
    assert_equal 'Invalid CSS after "  *bar:baz ": expected ";", was "[fail]; }"', e.message
    assert_equal 2, e.sass_line
  end

  def test_uses_property_exception_with_colon_hack
    render <<SCSS
foo {
  :bar:baz [fail]; }
SCSS
    assert(false, "Expected syntax error")
  rescue Sass::SyntaxError => e
    assert_equal 'Invalid CSS after "  :bar:baz ": expected ";", was "[fail]; }"', e.message
    assert_equal 2, e.sass_line
  end

  def test_uses_rule_exception_with_dot_hack
    render <<SCSS
foo {
  .bar:baz <fail>; }
SCSS
    assert(false, "Expected syntax error")
  rescue Sass::SyntaxError => e
    assert_equal 'Invalid CSS after "  .bar:baz ": expected "{", was "<fail>; }"', e.message
    assert_equal 2, e.sass_line
  end

  def test_uses_property_exception_with_space_after_name
    render <<SCSS
foo {
  bar: baz [fail]; }
SCSS
    assert(false, "Expected syntax error")
  rescue Sass::SyntaxError => e
    assert_equal 'Invalid CSS after "  bar: baz ": expected ";", was "[fail]; }"', e.message
    assert_equal 2, e.sass_line
  end

  def test_uses_property_exception_with_non_identifier_after_name
    render <<SCSS
foo {
  bar:1px [fail]; }
SCSS
    assert(false, "Expected syntax error")
  rescue Sass::SyntaxError => e
    assert_equal 'Invalid CSS after "  bar:1px ": expected ";", was "[fail]; }"', e.message
    assert_equal 2, e.sass_line
  end

  def test_uses_property_exception_when_followed_by_open_bracket
    render <<SCSS
foo {
  bar:{baz: .fail} }
SCSS
    assert(false, "Expected syntax error")
  rescue Sass::SyntaxError => e
    assert_equal 'Invalid CSS after "  bar:{baz: ": expected expression (e.g. 1px, bold), was ".fail} }"', e.message
    assert_equal 2, e.sass_line
  end

  def test_script_error
    render <<SCSS
foo {
  bar: "baz" * * }
SCSS
    assert(false, "Expected syntax error")
  rescue Sass::SyntaxError => e
    assert_equal 'Invalid CSS after "  bar: "baz" * ": expected expression (e.g. 1px, bold), was "* }"', e.message
    assert_equal 2, e.sass_line
  end

  def test_multiline_script_syntax_error
    render <<SCSS
foo {
  bar:
    "baz" * * }
SCSS
    assert(false, "Expected syntax error")
  rescue Sass::SyntaxError => e
    assert_equal 'Invalid CSS after "    "baz" * ": expected expression (e.g. 1px, bold), was "* }"', e.message
    assert_equal 3, e.sass_line
  end

  def test_multiline_script_runtime_error
    render <<SCSS
foo {
  bar: "baz" +
    "bar" +
    $bang }
SCSS
    assert(false, "Expected syntax error")
  rescue Sass::SyntaxError => e
    assert_equal "Undefined variable: \"$bang\".", e.message
    assert_equal 4, e.sass_line
  end

  def test_post_multiline_script_runtime_error
    render <<SCSS
foo {
  bar: "baz" +
    "bar" +
    "baz";
  bip: $bop; }
SCSS
    assert(false, "Expected syntax error")
  rescue Sass::SyntaxError => e
    assert_equal "Undefined variable: \"$bop\".", e.message
    assert_equal 5, e.sass_line
  end

  def test_multiline_property_runtime_error
    render <<SCSS
foo {
  bar: baz
    bar
    \#{$bang} }
SCSS
    assert(false, "Expected syntax error")
  rescue Sass::SyntaxError => e
    assert_equal "Undefined variable: \"$bang\".", e.message
    assert_equal 4, e.sass_line
  end

  def test_post_resolution_selector_error
    render "\n\nfoo \#{\") bar\"} {a: b}"
    assert(false, "Expected syntax error")
  rescue Sass::SyntaxError => e
    assert_equal 'Invalid CSS after "foo ": expected selector, was ") bar"', e.message
    assert_equal 3, e.sass_line
  end

  def test_parent_in_mid_selector_error
    assert_raise(Sass::SyntaxError, <<MESSAGE) {render <<SCSS}
Invalid CSS after ".foo": expected "{", was "&.bar"

In Sass 3, the parent selector & can only be used where element names are valid,
since it could potentially be replaced by an element name.
MESSAGE
flim {
  .foo&.bar {a: b}
}
SCSS
  end

  def test_parent_in_mid_selector_error
    assert_raise(Sass::SyntaxError, <<MESSAGE) {render <<SCSS}
Invalid CSS after ".foo.bar": expected "{", was "&"

In Sass 3, the parent selector & can only be used where element names are valid,
since it could potentially be replaced by an element name.
MESSAGE
flim {
  .foo.bar& {a: b}
}
SCSS
  end

  def test_double_parent_selector_error
    assert_raise(Sass::SyntaxError, <<MESSAGE) {render <<SCSS}
Invalid CSS after "&": expected "{", was "&"

In Sass 3, the parent selector & can only be used where element names are valid,
since it could potentially be replaced by an element name.
MESSAGE
flim {
  && {a: b}
}
SCSS
  end

  # Regression

  def test_weird_added_space
    assert_equal <<CSS, render(<<SCSS)
foo {
  bar: -moz-bip; }
CSS
$value : bip;

foo {
  bar: -moz-\#{$value};
}
SCSS
  end

  def test_extra_comma_in_mixin_arglist_error
    assert_raise(Sass::SyntaxError, <<MESSAGE) {render <<SCSS}
Invalid CSS after "@include foo(bar, ": expected mixin argument, was ")"
MESSAGE
@mixin foo($a1, $a2) {
  baz: $a1 $a2;
}

.bar {
  @include foo(bar, );
}
SCSS
  end
end
