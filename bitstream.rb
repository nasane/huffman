=begin

This provides bit-by-bit io support.
Ported to Ruby by Nathan Bossart.

Modeled after Dr. Goldwasser's programming assignments linked below:
http://cs.slu.edu/~goldwasser/courses/slu/csci180/2012_Spring/assignments/programs/decode/
http://cs.slu.edu/~goldwasser/courses/slu/csci180/2012_Spring/assignments/programs/encode/

=end


# provide bit-by-bit write ability to a file
class OutBitStream

  def _clear
    @buffer  = 0
    @bufsize = 0
  end

  def initialize
    @FULLWORD = 8
    @buffer = @bufsize = @byteswritten = 0
    @file = nil
  end

  def isOpen
    if @file!=nil
      !(@file.closed?)
    end
  end

  def _rawdump(value, numbits)
    numMissing = @FULLWORD-@bufsize
    shift      = numbits-numMissing
    prefix     = value>>shift
    @buffer  <<= numMissing
    @buffer   += prefix
    @file.write(@buffer.chr)
    @byteswritten += 1
    _clear
    return (numbits-numMissing)
  end

  def open(filename)
    if isOpen
      close
    end
    @file = File.open(filename, "w")
    _clear
    @byteswritten = 0
    return isOpen
  end

  def write(value, numbits)
    if isOpen && numbits>0
      if @byteswritten >= 50000000
        puts("Warning! OutBitStream is being automatically closed")
        puts("         as the file size is surpassing a safe limit")
        close
        return
      end
      cleanvalue = value & ((1 << numbits) - 1)
      if @bufsize+numbits < @FULLWORD
        @bufsize += numbits
        @buffer <<= numbits
        @buffer  += cleanvalue
      else
        bitsLeft = _rawdump(cleanvalue, numbits)
        suffix   = cleanvalue & ((1 << bitsLeft) - 1)
        write(suffix, bitsLeft)
      end
    end
  end

  def close
    if isOpen
      if @bufsize!=0
        _rawdump(0, @FULLWORD-@bufsize)
      end
      @file.close
    end
  end

end



# provide bit-by-bit read ability on a file
class InBitStream

  def _clear
    @buffer  = 0
    @bufsize = 0
  end

  def initialize
    @FULLWORD = 8
    @buffer = @bufsize = 0
    @file = nil
  end

  def isOpen
    if @file!=nil
      return !(@file.closed?)
    end
    return false
  end

  def eof
    return @bufsize==0 && @file.eof
  end

  def open(filename)
    if isOpen
      close
    end
    @file = File.open(filename, "r")
    _clear
    _prefetch
    isOpen
  end

  def _prefetch
    if isOpen && @bufsize==0
      check   = @file.eof
      @buffer = @file.getbyte
      if check
        @buffer = 0
      else
        @bufsize = @FULLWORD
      end
    end
  end

  def read(numbits)
    if isOpen
      result = 0
      if numbits==1
        if @bufsize>0
          result    = @buffer>>(@bufsize-1)
          @buffer  -= result<<(@bufsize-1)
          @bufsize -= 1
          if @bufsize==0
            _prefetch
          end
        end
      else
        for i in 0..(numbits-1)
          result = (result << 1) + read(1)
        end
      end
      return result
    end
    return -1
  end

  def close
    if isOpen
      @file.close
    end
  end

end
