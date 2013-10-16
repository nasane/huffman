=begin

This provides a linked binary tree implementation.
Ported to Ruby by Nathan Bossart.

Modeled after Dr. Goldwasser's programming assignments linked below:
http://cs.slu.edu/~goldwasser/courses/slu/csci180/2012_Spring/assignments/programs/decode/
http://cs.slu.edu/~goldwasser/courses/slu/csci180/2012_Spring/assignments/programs/encode/

=end


# linked binary tree implementation
class LinkedBinaryTree

  attr_accessor :value
  attr_accessor :parent
  attr_accessor :left
  attr_accessor :right

  def initialize(value=nil, parent=nil)
    @value  = value
    @parent = parent
    @left   = nil
    @right  = nil
  end

  def empty?
    @value==nil
  end

  def external?
    @left==nil && @right==nil
  end

  def addRoot(value=nil)
    @value  = value
    @parent = nil
    @left   = nil
    @right  = nil
  end

  def root
    if @parent==nil
      return self
    else
      return @parent.root
    end
  end

  def hasLeftChild?
    @left!=nil
  end

  def hasRightChild?
    @right!=nil
  end

  def expandExternal(pos)  # provide an external node
    if pos.external?
      pos.left  = LinkedBinaryTree.new(nil, pos)
      pos.right = LinkedBinaryTree.new(nil, pos)
    else
      puts("An error occurred when trying to expand an already-internal node.")
    end
  end

  def removeAboveExternal(pos)
    if pos.external?
      sib = pos==pos.parent.left ? @parent.right : @parent.left
      if @parent.parent==nil  # if parent is root
        @parent     = sib
        sib.parent = nil
      else
        grand = @parent.parent
        if @parent==grand.left
          grand.left = sib
        else
          grand.right = sib
        end
        sib.parent = grand
      end
      pos.parent.delete
      pos.delete
      return sib
    else
      puts("An error occurred when trying to removeAboveExternal an internal node.")
    end
  end

  def replaceExternalWithSubtree(pos, tree)
    if pos.external?
      if @parent!=nil  # if @pos is root
        tree.parent = pos.parent
        if pos==@parent.left
          @parent.left = tree.parent
        else
          @parent.right = tree.parent
        end
      end
      # pos.delete
    else
      puts("An error occurred when trying to replaceExternalWithSubtree an internal node.")
    end
  end

end
