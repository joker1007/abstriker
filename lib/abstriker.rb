require "abstriker/version"
require "set"

module Abstriker
  class NotImplementedError < NotImplementedError
    attr_reader :subclass, :abstract_method

    def initialize(klass, abstract_method)
      super("#{abstract_method} is abstract, but not implemented by #{klass}")
      @subclass = klass
      @abstract_method = abstract_method
    end
  end

  @disable = false

  def self.disable=(v)
    @disable = v
  end

  def self.disabled?
    @disable
  end

  def self.enabled?
    !disabled?
  end

  def self.abstract_methods
    @abstract_methods ||= {}
  end

  def self.extended(base)
    base.extend(SyntaxMethods)
    base.singleton_class.extend(SyntaxMethods)
    if enabled?
      base.extend(ModuleMethods) if base.is_a?(Module)
      base.extend(ClassMethods) if base.is_a?(Class)
    end
  end

  module SyntaxMethods
    private

    def abstract(symbol)
      method_set = Abstriker.abstract_methods[self] ||= Set.new
      method_set.add(symbol)
    end
  end

  module HookBase
    private

    def detect_event_type
      caller_info = caller_locations(3, 1)[0]
      if caller_info.label.match?(/block/)
        [:end, :raise]
      elsif caller_info.label.match?(/initialize/) || caller_info.label.match?(/new/)
        [:c_return, :b_call, :b_return, :raise]
      end
    end

    def check_abstract_methods(klass, block_count_offset = 0)
      return if Abstriker.disabled?

      event_type = detect_event_type

      unless klass.instance_variable_get("@__abstract_trace_point")
        block_count = block_count_offset

        tp = TracePoint.trace(*event_type) do |t|
          if t.event == :raise
            tp.disable
            next
          end

          block_count += 1 if t.event == :b_call
          block_count -= 1 if t.event == :b_return

          t_self = t.self
          target_end_event = t_self == klass && t.event == :end
          target_b_return_event = t_self == klass && t.event == :b_return && block_count.zero?
          target_c_return_event = t_self == Class && t.event == :c_return && t.method_id == :new
          if target_end_event || target_b_return_event || target_c_return_event
            klass.ancestors.drop(1).each do |mod|
              Abstriker.abstract_methods[mod]&.each do |fmeth_name|
                meth = klass.instance_method(fmeth_name)
                if meth.owner == mod
                  tp.disable
                  klass.instance_variable_set("@__abstract_trace_point", nil)
                  raise Abstriker::NotImplementedError.new(klass, meth)
                end
              end
            end
            tp.disable
            klass.instance_variable_set("@__abstract_trace_point", nil)
          end
        end
        klass.instance_variable_set("@__abstract_trace_point", tp)
      end
    end

    def check_abstract_singleton_methods(klass, block_count_offset = 0)
      return if Abstriker.disabled?

      event_type = detect_event_type

      unless klass.instance_variable_get("@__abstract_singleton_trace_point")
        block_count = block_count_offset

        tp = TracePoint.trace(*event_type) do |t|
          if t.event == :raise
            tp.disable
            next
          end

          block_count += 1 if t.event == :b_call
          block_count -= 1 if t.event == :b_return

          t_self = t.self
          target_end_event = t_self == klass && t.event == :end
          target_b_return_event = t_self == klass && t.event == :b_return && block_count.zero?
          target_c_return_event = t_self == Class && t.event == :c_return && t.method_id == :new
          if target_end_event || target_b_return_event || target_c_return_event
            klass.singleton_class.ancestors.drop(1).each do |mod|
              Abstriker.abstract_methods[mod]&.each do |fmeth_name|
                meth = klass.singleton_class.instance_method(fmeth_name)
                if meth.owner == mod
                  tp.disable
                  klass.instance_variable_set("@__abstract_singleton_trace_point", nil)
                  raise Abstriker::NotImplementedError.new(klass, meth)
                end
              end
            end
            tp.disable
            klass.instance_variable_set("@__abstract_singleton_trace_point", nil)
          end
        end
        klass.instance_variable_set("@__abstract_singleton_trace_point", tp)
      end
    end
  end

  module ClassMethods
    include HookBase

    private

    def inherited(subclass)
      check_abstract_methods(subclass)
      check_abstract_singleton_methods(subclass)
    end
  end

  module ModuleMethods
    include HookBase

    private

    def included(base)
      check_abstract_methods(base, 1)
    end

    def extended(base)
      check_abstract_singleton_methods(base, 1)
    end
  end
end
