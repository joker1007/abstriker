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

    def check_abstract_methods(klass)
      return if Abstriker.disabled?

      unless klass.instance_variable_get("@__abstract_trace_point")
        tp = TracePoint.trace(:end, :c_return, :raise) do |t|
          if t.event == :raise
            tp.disable
            next
          end

          t_self = t.self
          target_end_event = t_self == klass && t.event == :end
          target_c_return_event = (t_self == Class || t_self == Module) && t.event == :c_return && t.method_id == :new
          if target_end_event || target_c_return_event
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

    def check_abstract_singleton_methods(klass)
      return if Abstriker.disabled?

      unless klass.instance_variable_get("@__abstract_singleton_trace_point")

        tp = TracePoint.trace(:end, :c_return, :raise) do |t|
          if t.event == :raise
            tp.disable
            next
          end

          t_self = t.self
          target_end_event = t_self == klass && t.event == :end
          target_c_return_event = (t_self == Class || t_self == Module) && t.event == :c_return && t.method_id == :new
          if target_end_event || target_c_return_event
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
      check_abstract_methods(base)
    end

    def extended(base)
      check_abstract_singleton_methods(base)
    end
  end
end
