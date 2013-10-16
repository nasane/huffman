#!/usr/bin/ruby


=begin

This compresses a file with Huffman encoding.
Written by Nathan Bossart.

Modeled after Dr. Goldwasser's programming assignments linked below:
http://cs.slu.edu/~goldwasser/courses/slu/csci180/2012_Spring/assignments/programs/decode/
http://cs.slu.edu/~goldwasser/courses/slu/csci180/2012_Spring/assignments/programs/encode/

=end


require_relative 'bitstream'
require_relative 'binarytree'
require          'rubygems'
require          'algorithms'



class Pair
  attr_accessor :one, :two

  def initialize(one, two)
    @one = one
    @two = two
  end
end



class Encode


  def initialize(inputfile, outputfile)
    # perform file name/path checking
    @inputfile  = inputfile
    @outputfile = outputfile
    encode(@inputfile, @outputfile)
  end


  def developHuffmanTree(frequencies)
    q = Containers::PriorityQueue.new
    for i in 0..256
      if frequencies[i]>0
        tree = LinkedBinaryTree.new(i, nil)
        pairForQueue = Pair.new(frequencies[i], tree)
        q.push(pairForQueue, -frequencies[i])
      end
    end
    while q.size>1
      freq1 = q.next.one
      tree1 = q.next.two
      q.pop
      freq2 = q.next.one
      tree2 = q.next.two
      q.pop
      newTree = LinkedBinaryTree.new(nil, nil)
      newTree.left  = tree1
      newTree.right = tree2
      newTree.left.parent  = newTree
      newTree.right.parent = newTree
      revisedPairForQueue = Pair.new(freq1+freq2, newTree)
      q.push(revisedPairForQueue, -(freq1+freq2))
    end
    return q.next.two
  end


  def buildCodes(walk, currentCode, codes)
    if walk.external?
      codes[walk.value] = currentCode.clone
    else
      if walk.left!=nil
        buildCodes(walk.left, currentCode.clone+"0", codes)
      end
      if walk.right!=nil
        buildCodes(walk.right, currentCode.clone+"1", codes)
      end
    end
  end


  def printCodes(walk, output)
    if walk.external?
      output.write(1,1)
      if walk.value!=256
        output.write(0,1)
        output.write(walk.value,8)
      else
        output.write(walk.value,9)
      end
    else
      output.write(0,1)
      if walk.left!=nil
        printCodes(walk.left, output)
      end
      if walk.right!=nil
        printCodes(walk.right, output)
      end
    end
  end


  def encode(inputfile, outputfile)

    input  = InBitStream.new
    output = OutBitStream.new

    input.open(inputfile)
    output.open(outputfile)

    frequencies = Array.new(257) { |e| e = 0 }
    frequencies[256] += 1
    while !(input.eof)
      character = input.read(8)
      frequencies[character] += 1
    end
    input.close

    codingTree = developHuffmanTree(frequencies)
    codes = Array.new(257)
    buildCodes(codingTree, "", codes)
    printCodes(codingTree, output)

    input.open(inputfile)
    while !(input.eof)
      character    = input.read(8)
      size         = codes[character].size
      codeToOutput = codes[character]
      for i in 0..size-1
        if codeToOutput[i]=="0"
          output.write(0,1)
        else
          output.write(1,1)
        end
      end
    end
    eom     = codes[256]
    eomSize = eom.size
    for i in 0..eomSize-1
      if eom[i]=="0"
        output.write(0,1)
      else
        output.write(1,1)
      end
    end
    output.close

  end
end
