# encoding: windows-1252 :encoding=Windows-1252: 

$fixedpnt_track_min_max ||= false

##########################################################################
##########################################################################
# == DESCRIPTION
# 
# Binary Fixed Point calculations with Ruby.
# 
# This code is deeply inspired by:
# * Phil Tomson: fixedpt.rb: http://rubyforge.org/projects/fixedpt/
# Thank you to Brian Candler for giving me very helpfull tips:
# http://www.ruby-forum.com/topic/4408936#new
# If you want to know what fixed point numbers are, you can read this: 
# http://en.wikipedia.org/wiki/Fixed-point_arithmetic
# 
# 
# == FEATURES/PROBLEMS:
# 
# GOALS: 
# * Simulating fixed point calculations done in hardware
# * Relatively fast (pure Ruby, for I don't know C...) 
# * The fixed point format of the result of an expression shall be the same as
#   with Matlab. Example: Lets x and y each be 4 bits long with the binary point
#   at one place from right. With z = x * y, z will have a length of 8 bits 
#   with the binary point at two places from right.
# 
# IT HAS: 
# * tracking (at the very end you can read the min and max value a variable was assigned to)
# * "Inheritance" of fixed-point format ("right" format will be calculated automatically);
# * Overflow check;
# 
# IT HAS _NOT_: 
# * OVERFLOW: NO overflow handler; instead: raises error;
# * NO COERCE;
# * Syntax _not_ Matlab-compatible; 
# * no rounding; 
# * SIGNED only.
# * As of now, NO DIVISION (I did not need it)
# 
# KNOWN ISSUES:
# * Exception raising on overflow isn't well done.
# 
# 
# == SYNOPSIS:
# 
# EXAMPLE USAGE:
#   require 'fixedpnt'
#   include FixedPntModule
#   $fixedpnt_track_min_max = true
#   
#   a = fp(64, 8) 
#   b = fp(64, 8) 
#   c = fp
#   
#   10000.times do |i| 
#     a.assign( i )
#     b.assign( 2.2 * i ) 
#     if  i > 5000 
#       c.is a - b 
#     else 
#       c.is a + b 
#     end 
#   end    
#   
#   puts "a.abs_min_max = "  + a.abs_min_max.inspect  #=> [0.0, 99999.0]
#   puts "b.abs_min_max = "  + b.abs_min_max.inspect  #=> [0.0, 219997.796875] 
#   puts "c.abs_min_max = "  + c.abs_min_max.inspect  #=> [-119998.796875, 160000.0]
#   puts "c.format = " + c.format.inspect   #=> [65, 57, 8]
#   p required_fp_format(0.001, 220000)     #=> [30, 10]
# 
# 
# GENERAL USAGE: 
# 
# CREATION:
# FixedPnt.new(total_bits=nil, frac_width=nil, value=nil)
# 
# fp1 = FixedPnt.new(32,16, 1.234)
#   * Sets fixed-point format to:
#   ** total number of bits, including sign = 32; 
#   ** number of fractional bits = 16; 
#    (Total number of bits may be smaller than number of fractional bits.)
#   * Sets value to 1.234; 
# fp1 = FixedPnt.new(32,16)
#   * Sets fixed-point format;
#   * Value is assigned later;
# fp1 = FixedPnt.new()
#   * Fixed-point format and value are assigned later;
#   * Usefull for format-"inheritance"
#   * Usefull for min-max-tracking
# 
# SHORTCUT to FixedPnt.new(...):
#   include FixedPntModule
#   fp(...)
# 
# ASSIGNMENT ( # # #  IMPORTANT !! # # # )
# 
# "fp1 = ...": 
#    Use this in rare cases only! 
#    ("=": Assignment of variable name to object.) 
# 
# instead, use (for speed and tracking):
# 
# "fp2.is(fp1)":
#    Sets value (and format) of fp2 to equal fp1. 
#    fp2 and fp1 must have same format, OR: 
#    fp2's format is automatically taken from fp1
#    ("inherited"), OR raises error if formats are different.
# "fp3.is(fp1 + fp2"): 
#    fp3 and "fp1 + fp2" must have same format, OR: 
#    fp3's format is automatically taken from "fp1 + fp2" 
#    ("inherited"), OR raises error if formats are different.
#  "fp1.assign( a_float)" or "fp1.assign( an_integer )":
#     Assignes value to fp1. 
# "fp2.fit(fp1)":
#   Use this to reformat ("resize") fp1. 
# 
# MEMORIZE:
# "is": left and right side are FixedPnt, formats are equal or automtically set;
# "fit": left and right side are FixedPnt, formats are unequal;
# "assign": left is FixedPnt, right is Numeric;
#     
# MIN-MAX-TRACKING:
#   Stores min and max value ever assigned to this fixed-point instance.
#   Tracking can be disabled by setting:
#     $fixedpnt_track_min_max = false ;
# 
# 
# == REQUIREMENTS:
# 
# * Ruby 1.8.7 or higher
# 
# (I used it with Ruby 1.8.7 and 1.9.3.)
# 
# 
# == INSTALL:
# 
# * sudo gem install fixedpnt
# 
# == LICENSE:
# 
# (The MIT License)
# 
# Copyright (c) 2013 Axel Friedrich and contributors (see the CONTRIBUTORS file)
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# FOR INFORMATION: 
# 
# Privat methods:
# overflow?: 
#   checks for overflow;
# equal_formats?: 
#   checks for equal fixed-point formats (not an explicit method);
# track_min_max__: 
#   stores min and max value ever assigned to this fixed-point instance;
# limits!:
#   sets the upper and lower assignable value for this fixed-point instance;
# 
#|_. method       |_. overflow? |_. equal_formats?  |_. track_min_max__ |_. limits! |_.  Note              |
#| new()          |  N(o)       |  N                |   N               |   N       | (1)                  |
#| new(tw,fw)     |  N(o)       |  N                |   N               |   N       | (1)                  |
#| new(tw,fw,val) |  Y(es)      |  N                |   Y               |   Y       | (1)                  |
#| .assign        |  Y          |  N                |   Y               | Y (once)  |                      |
#| .is            |  N          |Y or assign format |   Y               |   N       |                      |
#| =              |  N          |  N                |   N               |   N       |assignment to varname |
#|                |             |                   |                   |           |                      |
#  
# (1): "new" sets: 
#   * @stored_int = nil, if no value given;
#   * @bits, @frac_width, @int_width  if FixedPnt.new(fixnum, fixnum)
#   * @bits=@frac_width=@int_width=nil  if FixedPnt.new(nil, nil)  # for format-inheritance 
#  
class FixedPnt
  VERSION = "0.0.2"

  attr_reader  :bits, :int_width, :frac_width 
  attr_accessor  :stored_int, :min_assigned_int, :max_assigned_int

  ##################################################################
  # "a = FixedPnt.new"  returns fixed-point object with unset format. This is
  # usefull for automatic assigning format; example:
  # a = FixedPnt.new
  # b = FixedPnt.new(16,8, 1.23)
  # a = b + b  # a's format will be set automatically
  # 
  def initialize(total_bits=nil, frac_width=nil, value=nil )
    @bits = total_bits # total number of bits
    @frac_width = frac_width

    @stored_int = nil
    @max_stored_int = nil # max allowed value of the stored integer for the given format. 
    @min_stored_int = nil # min allowed value of the stored integer for the given format. 
    @int_width = @bits - @frac_width if @frac_width # Width of the integer part ("part left of binary point") of the stored integer incl. 1 Bit for sign 
    @min_assigned_int =  nil # min value (as stored integer), which was tried to be assigned to this fixed-point. TODO: Replace 999999999.
    @max_assigned_int = nil # max value (as stored integer), which was tried to be assigned to this fixed-point. TODO: Replace 999999999.
    
    self.assign(value) if value
  end # initialize

  ##################################################################
  # Assign a Float or Integer value
  def assign( assigned_value )
    @assigned_value = assigned_value

    # TODO: Improve speed?
    case @assigned_value
    when Float
      limits!  unless @max_stored_int
      @stored_int =   (@assigned_value * 2**@frac_width).to_i
      overflow?
    when Fixnum
      limits!  unless @max_stored_int
      @stored_int =   @assigned_value << @frac_width
      overflow?
    else
      raise
    end

    track_min_max__  if $fixedpnt_track_min_max

    self 
  end # assign
  alias :[]=  :assign

  ##################################################################
  # Convert  fixed_point  into another fixed-point format ("resize").
  def fit( fixed_point )
    @assigned_value = fixed_point

    limits!  unless @max_stored_int
    @stored_int = @assigned_value.stored_int << (@frac_width - @assigned_value.frac_width )
    overflow?  ## if @int_width < @assigned_value.int_width

    track_min_max__  if $fixedpnt_track_min_max

    self 
  end # fit
  

  ##################################################################
  # other: fixed_point of same format
  # Assignes other to self.
  # Advantage over a simple "=": tracking possible
  def is( other )
    @assigned_value = other

    unless @frac_width # TODO: Using Nil-class and mutate class possible? (-> a.=_... with a == nil )
      @bits = other.bits
      @int_width = other.int_width
      @frac_width = other.frac_width
    else
      if @bits != other.bits  || @frac_width != other.frac_width
        raise "!!!! ERROR: Fixed-point formats must equal, but self.format=#{ self.format.inspect } and other.format = #{ other.format.inspect }!"
      end
    end
    
    @stored_int = other.stored_int
    track_min_max__  if $fixedpnt_track_min_max

    self
  end # _=
  

  ##################################################################
  # +    
  # int_width = [self.int_width, other.int_width].max + 1 
  # frac_width = [self.frac_width, other.frac_width].max
  # overflow_handler = self.overflow_handler
  def +(other) # c = a + b ->  c.bits = [a.bits, b.bits].max + 1  (like Matlab)
    # TODO: Can speed be improved?
    sif = self.int_width
    oif = other.int_width

    if oif > sif
      int_width = oif + 1
    else
      int_width = sif + 1
    end

    sfw = self.frac_width
    ofw = other.frac_width

    if ofw > sfw
      frac_width = ofw
    else
      frac_width = sfw
    end

    # int_width = [self.int_width, other.int_width].max + 1   # slower
    # frac_width = [self.frac_width, other.frac_width].max    # slower
    bits = int_width + frac_width

    s = @stored_int
    o = other.stored_int

    frac_diff = @frac_width - other.frac_width

    if frac_diff > 0 
      o = o << frac_diff
    else
      s = s << -frac_diff
    end

    res = FixedPnt.new(bits, frac_width)
    res.stored_int = s + o 
    res
  end

  ##################################################################
  # Unary operator "-"
  def -@
    if @stored_int == @min_stored_int
      raise "@stored_int must not equal @min_stored_int!"
    end

    res = self.dup # TODO: faster way? 
    res.stored_int = - res.stored_int
    res.min_assigned_int =  999999999
    res.max_assigned_int = -999999999
    ##/ res.track_min_max__ if $fixedpnt_track_min_max
    res
  end # -@

  ##################################################################
  # -   
  def -(other)
    # TODO: Can speed be improved?
    sif = self.int_width
    oif = other.int_width

    if oif > sif
      int_width = oif + 1
    else
      int_width = sif + 1
    end

    sfw = self.frac_width
    ofw = other.frac_width

    if ofw > sfw
      frac_width = ofw
    else
      frac_width = sfw
    end

    # int_width = [self.int_width, other.int_width].max + 1   # slower
    # frac_width = [self.frac_width, other.frac_width].max    # slower
    bits = int_width + frac_width

    s = @stored_int
    o = other.stored_int

    frac_diff = @frac_width - other.frac_width

    if frac_diff > 0 
      o = o << frac_diff
    else
      s = s << -frac_diff
    end

    res = FixedPnt.new(bits, frac_width)
    res.stored_int = s - o 
    res
  end

  ##################################################################
  # Matlab says for signed fixed-points:
  #   For c = a * b:
  #   c.int_width = a.int_width + b.int_width # IMHO, a.int_width + b.int_width - 1 would be sufficient 
  #   c.frac_width = a.frac_width + b.frac_width
  def *(other)
    int_width  = @int_width + other.int_width # IMHO, a.int_width + b.int_width - 1 would be sufficient 
    frac_width = @frac_width + other.frac_width
    bits = int_width + frac_width

    res = FixedPnt.new(bits, frac_width)
    res.stored_int = self.stored_int * other.stored_int 
    res
  end
  
  def to_i(  )
    res = (@stored_int >> @frac_width)
    res = res + 1  if @stored_int < 0
    res
  end # to_i

  def to_int
    to_i
  end

  def to_f(  )
    # Thanks to Brian Candler.
    self.stored_int * 1.0 / (1 << @frac_width)
  end # to_f

  ##################################################################
  # Returns the stored integer of the fixed point value.
  # THE FIRST BIT IS FOR SIGN!
  # Returns: String; Liefert die Integer-Darstellung (ohne virtuellen Punkt)
  # TODO: Improve?
  def to_bin
    return nil unless @stored_int

    #str = sprintf("%0#{@bits}b",@ival)
    str = if @stored_int < 0
      sprintf("%0#{@bits}b",2**@bits + @stored_int)
    else
      sprintf("%0#{@bits}b",@stored_int)
    end
    return str
  end

  ##################################################################
  # Returns the binary representation of the stored integer with the virtual
  # binary point inserted. THE FIRST BIT IS FOR SIGN!
  # TODO: Improve?
  def to_binary
    return nil unless @stored_int

    str = self.to_bin
    values = str.split('')
    tmp = @bits-@frac_width
    if tmp >= 0
      values.insert(@bits-@frac_width,".")
    else
      values.insert(0, "x.#{ 'x' * tmp.abs }")
    end
    values.join('')
  end

  ##################################################################
  # Returns the actual Fixed Point format as
  # [total_number_of_bits, int_width_including_sign, frac_width] .
  # Actually without the signed/unsigned flag
  def format(  )
    [ @bits, @int_width,  @frac_width]
  end # format

  
  def track_min_max__(  ) # for internal use only!
    if !@min_assigned_int ||  @stored_int < @min_assigned_int
      @min_assigned_int = @stored_int
    end
    
    if !@max_assigned_int ||  @stored_int > @max_assigned_int
      @max_assigned_int = @stored_int
    end
                                
    ## @min_assigned_int = [@stored_int, @min_assigned_int].min # Probably slower 
    ## @max_assigned_int = [@stored_int, @max_assigned_int].max # Probably slower 
    nil
  end # track_min_max__

  ##################################################################
  # Returns min and max assignable values as Array.
  def limits(  )
    limits!
    mi = @min_stored_int * 1.0 / (1 << @frac_width)
    ma = @max_stored_int * 1.0 / (1 << @frac_width)

    [ mi, ma ]
  end # limits
  

  ##################################################################
  # Returns [min_assigned_value, max_assigned_value], where: 
  # min_assigned_value: min value, which ever was tried to be assigned to this
  # fixed-point instance.
  # max_assigned_value: max value, which ever was tried to be assigned to this
  # fixed-point instance.
  def abs_min_max(  )
    mi = @min_assigned_int * 1.0 / (1 << @frac_width)
    ma = @max_assigned_int * 1.0 / (1 << @frac_width)

    [ mi, ma ]  
  end # abs_min_max

  ##################################################################
  # Returns [min_assigned_value, max_assigned_value], where: 
  # min_assigned_value: min value, which ever was tried to be assigned to this
  # fixed-point instance, divided by min allowed value for this fixed-point
  # format.
  # max_assigned_value: max value, which ever was tried to be assigned to this
  # fixed-point instance, divided by max allowed value for this fixed-point
  # format.
  def relative_min_max(  )
    limits!
    [ @min_assigned_int.to_f/@min_stored_int.to_f,   @max_assigned_int.to_f/@max_stored_int.to_f ]  
  end # relative_min_max



  private                                                                   
  def private____________________________(  )
  end # private____________________________
  
  def puts_overflow_msg(  )
    puts "\n!!!!!   ERROR: fixedpt_raise_on_overflow for @assigned_value #{ @assigned_value.inspect }"
    puts "@max_stored_int is             0b#{ @max_stored_int.to_s(2) }"
    puts "@min_stored_int is             0b#{ @min_stored_int.to_s(2) }"
    puts "but stored_int of val would be 0b#{ @stored_int.to_s(2) }"
    puts "  = #{ @stored_int.to_f/@max_stored_int } * max = #{ @stored_int.to_f/@min_stored_int } * min"
    puts "@assigned_value            = #{ @assigned_value  
           }"
    puts "@bits             = #{ @bits              }"
    puts "@int_width        = #{ @int_width         }"
    puts "@frac_width       = #{ @frac_width        }"
    puts "@stored_int       = #{ @stored_int        }"
    puts "@max_stored_int   = #{ @max_stored_int    }"
    puts "@min_stored_int   = #{ @min_stored_int    }"
    puts "@min_assigned_int = #{ @min_assigned_int  }"
    puts "@max_assigned_int = #{ @max_assigned_int  }"   
  end # puts_overflow_msg

  ##################################################################
  # 
  def overflow?( )
    if @stored_int > @max_stored_int  ||  @stored_int < @min_stored_int
      puts_overflow_msg
      raise "fixedpt_raise_on_overflow" 
    end
  end

  def limits!
    @max_stored_int = (1 << (@bits - 1)) - 1
    @min_stored_int =  -@max_stored_int - 1
  end
end # class FixedPnt


##################################################################
##################################################################
module FixedPntModule # TODO: Better way?
  def fp( *args )
    FixedPnt.new(*args)
  end # fi

  ##################################################################
  # Calculates the required Fixed-Point format for given
  # smallest_representable_value and biggest_overall_value.
  # Returns: [required_no_of_bits, required_fractional_width] 
  def required_fp_format(smallest_representable_value, biggest_overall_value  )
    smallest_bin_place = smallest_representable_value.max_significant_bin_place # "Nachkommastelle" -> negatives Vorzeichen
    biggest_bin_place = biggest_overall_value.max_significant_bin_place  # "Nachkommastelle" -> negatives Vorzeichen
    
    [(biggest_bin_place - smallest_bin_place + 2).to_i, (-smallest_bin_place).to_i]
  end # required_fp_format
  
end # module FixedPntModule

 
class Numeric
  ##################################################################
  # Returns the max significant place of the binary representation (TODO: right
  # wording?). Negative sign means that most significant binary place is right
  # from the binary point.
  # 
  # EXAMPLES: 
  # 33.max_significant_bin_place       -> 6 (33 = 0b100001) 
  # (1.0/33).max_significant_bin_place -> -6 (1/33 = 0b0.000001111100001) 
  def max_significant_bin_place(  )
    x = self.to_f.abs * 1.0000001 # 1.0000001 is for getting right values like 2**3 and 2**-3 TODO: Improve

    if x < 1
      x = 1.0 / x   
      sign = -1
    else
      sign = 1
    end

    x.to_i.to_s(2).size * sign
  end # max_significant_bin_place
end

##########################################################################
##########################################################################
if $0 == __FILE__

  include FixedPntModule
  $fixedpnt_track_min_max = true

  puts '###################### EXAMPLE USAGE '
  a = fp(64, 8) 
  b = fp(64, 8) 
  c = fp
  
  10000.times do |j| 
    a.assign( j )
    b.assign( 2.2 * j ) 
    if  j > 5000 
      c.is  a - b 
    else 
      c.is a + b 
    end 
  end    

  puts "a.abs_min_max = "  + a.abs_min_max.inspect               
  puts "b.abs_min_max = "  + b.abs_min_max.inspect               
  puts "c.abs_min_max = "  + c.abs_min_max.inspect
  puts "c.format = " + c.format.inspect

  # Calculates the required Fixed-Point format for given
  # smallest_representable_value and biggest_overall_value.
  p required_fp_format(0.001, 22000)              

end
