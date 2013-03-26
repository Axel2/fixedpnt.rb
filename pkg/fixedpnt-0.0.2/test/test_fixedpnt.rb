require "minitest/autorun"
begin
  require "fixedpnt"
rescue LoadError
  $: << File.dirname(File.dirname( File.expand_path( __FILE__ ) ).gsub('\\', '/')) + '/lib'
  require "fixedpnt"
end
include FixedPntModule

class TestFixedpnt < MiniTest::Unit::TestCase
  def setup
    $fixedpnt_track_min_max = true
  end
  def test_assign
    f = FixedPnt.new(32,16)
    f.assign( 3 )
    assert_equal  "0000000000000011.0000000000000000", f.to_binary
    f.assign( 3.5 )
    assert_equal  "0000000000000011.1000000000000000", f.to_binary
    f[]= -3
    assert_equal  "1111111111111101.0000000000000000", f.to_binary
    f.assign( -3.5 )
    assert_equal  "1111111111111100.1000000000000000", f.to_binary
  end
  
  def test_overflow(  )
    f = FixedPnt.new(3,0)
    f.assign( 3 )
    assert_equal  "011.", f.to_binary
    puts "\nSorry, PLEASE IGNORE the following error message:"
    assert_raises(RuntimeError) {|| f.assign( 4 ) } # TODO: Improve my exception

    f = FixedPnt.new(4,1)
    f.assign( 3 )
    assert_equal  "011.0", f.to_binary
    puts "\nSorry, PLEASE IGNORE the following error message:"
    assert_raises(RuntimeError) {|| f.assign( 5 ) }

    f = FixedPnt.new(3,0)
    f.assign( -3.5 )
    assert_equal  "101.", f.to_binary
    puts "\nSorry, PLEASE IGNORE the following error message:"
    assert_raises(RuntimeError) {|| f.assign( -5 ) }
  end # test_overflow
  
  def test_add(  )
    f = fp(4,0)
    f.assign( 2 )
    
    g = fp(4,0)
    g.assign( 3 )
    
    z = fp
    z.is f + g
    assert_equal  5.0 , z.to_f
    assert_equal  [5, 5, 0] , z.format
    assert_raises(RuntimeError) {|| z.is g } # TODO:  Improve my exception
  end # test_add
  
  def test_unary_minus(  )
    x = fp(4,0)
    x.assign( 3 )
    y = -x
    assert_equal(  -3.0 , y.to_f )
  end # test_unary_minus
  
  def test_substract(  )
    x = fp(4, 0)
    y = fp(4, 0)
    x.assign( 3 )
    y.assign( 5 )
    z = x - y
    assert_equal(  -2.0 , z.to_f )
    assert_equal  [5, 5, 0] , z.format
  end # test_substract
  
  def test_multiply(  )
    x = fp(4, 1)
    y = fp(4, 1)
    x.assign( -3 )
    y.assign( 3 )
    z = x * y
    assert_equal(  -9.0 , z.to_f )
    assert_equal  [8, 6, 2] , z.format
  end # test_multiply
  
  def test_to_i(  )
    y = -12.25
    x = fp(32, 16)
    x.assign( y )
    assert_equal(  -12.25 , x.to_f )
    assert_equal(  y.to_f , x.to_f )
    assert_equal(  -12 , x.to_i )
    assert_equal(  y.to_i , x.to_i )
  end # test_to_i
  
  def test_track_min_max(  )
    x = FixedPnt.new(32, 20)
  
    [0.5, 0.9 , 0.1, -0.3, 0.2].each {|val|
      x.assign( val )
      # y = FixedPnt.new(val, 1,10,9)
      # p y.to_f
      # x.update(y)
    }
    assert_in_delta( -2048.0, x.limits[0], 1e-6 )
    assert_in_delta(  2048.0, x.limits[1], 1e-6 )
    assert_in_delta(  -0.3, x.abs_min_max[0], 1e-6 )
    assert_in_delta(   0.9, x.abs_min_max[1], 1e-6 )
    assert_in_delta( 0.000146, x.relative_min_max[0], 1e-6 )
    assert_in_delta( 0.000439, x.relative_min_max[1], 1e-6 )
  end # test_track_min_max
end
