This code is deeply inspired by:
* Phil Tomson: fixedpt.rb: http://rubyforge.org/projects/fixedpt/
Thank you to Brian Candler for giving me very helpfull tips:
http://www.ruby-forum.com/topic/4408936#new
If you want to know what fixed point numbers are, you can read this: 
http://en.wikipedia.org/wiki/Fixed-point_arithmetic


EXAMPLE USAGE:
  require 'fixedpnt'
  include FixedPntModule
  $fixedpnt_track_min_max = true

  a = fp(64, 8) 
  b = fp(64, 8) 
  c = fp
  
  100000.times do |i| 
    a.assign( i )
    b.assign( 2.2 * i ) 
    if  i > 50000 
      c.is a - b 
    else 
      c.is a + b 
    end 
  end    

  puts "a.abs_min_max = "  + a.abs_min_max.inspect  #=> [0.0, 99999.0]
  puts "b.abs_min_max = "  + b.abs_min_max.inspect  #=> [0.0, 219997.796875] 
  puts "c.abs_min_max = "  + c.abs_min_max.inspect  #=> [-119998.796875, 160000.0]
  puts "c.format = " + c.format.inspect   #=> [65, 57, 8]
  p required_fp_format(0.001, 220000)     #=> [30, 10]


GOALS: 
* Simulating fixed point calculations done in hardware
* Relatively fast (pure Ruby, for I don't know C...) 
* The fixed point format of the result of an expression shall be the same as
  with Matlab. Example: Lets x and y each be 4 bits long with the binary point
  at one place from right. With z = x * y, z will have a length of 8 bits 
  with the binary point at two places from right.

IT HAS: 
* tracking (at the very end you can read the min and max value a variable was assigned to)
* "Inheritance" of fixed-point format ("right" format will be calculated automatically);
* Overflow check;

IT HAS _NOT_: 
* OVERFLOW: NO overflow handler; instead: raises error;
* NO COERCE;
* Syntax _not_ Matlab-compatible; 
* no rounding; 
* SIGNED only.
* As of now, NO DIVISION (I did not need it)

GENERAL USAGE: 

CREATION:
FixedPnt.new(total_bits=nil, frac_width=nil, value=nil)

fp1 = FixedPnt.new(32,16, 1.234)
  * Sets fixed-point format to:
  ** total number of bits, including sign = 32; 
  ** number of fractional bits = 16; 
   (Total number of bits may be smaller than number of fractional bits.)
  * Sets value to 1.234; 
fp1 = FixedPnt.new(32,16)
  * Sets fixed-point format;
  * Value is assigned later;
fp1 = FixedPnt.new()
  * Fixed-point format and value are assigned later;
  * Usefull for format-"inheritance"
  * Usefull for min-max-tracking

SHORTCUT to FixedPnt.new(...):
  include FixedPntModule
  fp(...)

ASSIGNMENT ( # # #  IMPORTANT !! # # # )

"fp1 = ...": 
   Use this in rare cases only! 
   ("=": Assignment of variable name to object.) 

instead, use (for speed and tracking):

"fp2.is(fp1)":
   Sets value (and format) of fp2 to equal fp1. 
   fp2 and fp1 must have same format, OR: 
   fp2's format is automatically taken from fp1
   ("inherited"), OR raises error if formats are different.
"fp3.is(fp1 + fp2"): 
   fp3 and "fp1 + fp2" must have same format, OR: 
   fp3's format is automatically taken from "fp1 + fp2" 
   ("inherited"), OR raises error if formats are different.
 "fp1.assign( a_float)" or "fp1.assign( an_integer )":
    Assignes value to fp1. 
"fp2.fit(fp1)":
  Use this to reformat ("resize") fp1. 

MEMORIZE:
"is": left and right side are FixedPnt, formats are equal or automtically set;
"fit": left and right side are FixedPnt, formats are unequal;
"assign": left is FixedPnt, right is Numeric;
    
MIN-MAX-TRACKING:
  Stores min and max value ever assigned to this fixed-point instance.
  Tracking can be disabled by setting:
    $fixedpnt_track_min_max = false ;
