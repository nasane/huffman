#!/usr/bin/ruby


=begin

This decompresses a Huffman-encoded file.
Written by Nathan Bossart.

Modeled after Dr. Goldwasser's programming assignments linked below:
http://cs.slu.edu/~goldwasser/courses/slu/csci180/2012_Spring/assignments/programs/decode/
http://cs.slu.edu/~goldwasser/courses/slu/csci180/2012_Spring/assignments/programs/encode/

=end


require_relative 'bitstream'
require_relative 'binarytree'


class Decode


  def initialize(inputfile, outputfile)
    # perform file name/path checking
    @inputfile  = inputfile
    @outputfile = outputfile
    decode(@inputfile, @outputfile)
  end


  def decode(inputfile, outputfile)

    input  = InBitStream.new
    output = OutBitStream.new

    input.open(inputfile)
    output.open(outputfile)

    numExternalNodes = numInternalNodes = 0
    key = LinkedBinaryTree.new
    while numExternalNodes!=(numInternalNodes+1)
      nextBit = input.read(1)
      if input.eof
        puts("Mal-formed header (eof reached prematurely)")
      end
      if nextBit==0
        numInternalNodes += 1
        if !(key.external?)
          key = key.right
        end
        key.expandExternal(key)
        key = key.left
      else
        numExternalNodes += 1
        endFlag = input.read(1)==1
        if endFlag
          key.value = false
          input.read(8)
        else
      key.value = input.read(8)
        end
        while key.parent.parent!=nil && key.parent.right==key
          key = key.parent
        end
        key = key.parent.right
      end
      if numExternalNodes>257
        puts("Mal-formed header (too many symbols defined in key)")
      end
    end

    eomCharReceived = false
    root = key.root
    while !input.eof && !eomCharReceived
      walk = root
      while !(walk.external?)
        nextBit = input.read(1)
        if nextBit==0
          walk = walk.left
        else
          walk = walk.right
        end
        if walk.external?
          if walk.value
            output.write(walk.value, 8)
          else
            eomCharReceived = true
          end
        end
      end
    end

    input.close
    output.close

    if !eomCharReceived
      puts("Warning: eof not found. Decompressed file generated to best of ability.")
    end

  end

end
