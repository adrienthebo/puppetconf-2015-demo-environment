#!/usr/bin/env ruby

require 'aasm'

class Manager
  include AASM

  aasm do
    state :start, :initial => true
    state :incrementing, :initial => true
    state :decrementing, :initial => true

    event :increment do
      transitions from: :start, to: :incrementing
    end
  end

  def foo
    require 'pry'; binding.pry
  end
end

Manager.new.foo
