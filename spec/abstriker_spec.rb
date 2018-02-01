RSpec.describe Abstriker do
  context "A1 class has abstract method" do
    before do
      class A1
        extend Abstriker

        abstract def foo
        end
      end
    end

    context "subclass not implement" do
      it "raise Abstriker::NotImplementedError", aggregate_failures: true do
        ex = nil
        begin
          class A2 < A1
          end
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
        expect(ex.subclass).to eq(A2)
        expect(ex.abstract_method.owner).to eq(A1)
        expect(ex.abstract_method.name).to eq(:foo)
      end
    end

    context "subclass implement" do
      it "does not raise" do
        class A3 < A1
          def foo
          end
        end

        class A5 < A3
        end
      end
    end

    context "Class.new(A1) and implement" do
      it "does not raise" do
        Class.new(A1) do
          pr = proc do
          end
          pr.call

          [1, 2, 3].each do |n|
            n * 2
          end

          define_method(:hoge) do
            puts "hoge"
          end

          def foo
            "hoge"
          end
        end
      end
    end

    context "subclass and raise exception" do
      it "does raise the exception" do
        ex = nil
        begin
          class A4 < A1
            raise "err"

            def foo
            end
          end
        rescue => e
          ex = e
        end

        expect(ex).to be_a(RuntimeError)
      end
    end

    context "Class.new(A1) and raise exception" do
      it "does raise the exception" do
        ex = nil
        begin
          Class.new(A1) do
            raise "err"

            def foo
            end
          end
        rescue => e
          ex = e
        end

        expect(ex).to be_a(RuntimeError)
      end
    end

    context "Class.new(A1) with no block" do
      it "raise Abstriker::NotImplementedError" do
        ex = nil
        begin
          Class.new(A1)
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
      end
    end

    context "subclass include refined module that has implementation" do
      module A7
      end

      using Module.new {
        refine A7 do
          def foo
          end
        end
      }

      it "does not raise" do
        ex = nil
        begin
          class A6 < A1
            include A7
          end
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
        expect(ex.subclass).to eq(A6)
        expect(ex.abstract_method.name).to eq(:foo)
        expect(A6.new.foo).to be_nil
      end
    end
  end

  context "B1 module has abstract method" do
    before do
      module B1
        extend Abstriker

        abstract def foo
        end
      end
    end

    context "class include B1 and not implement" do
      it "raise Abstriker::NotImplementedError", aggregate_failures: true do
        ex = nil
        begin
          class B2
            include B1
          end
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
        expect(ex.subclass).to eq(B2)
        expect(ex.abstract_method.owner).to eq(B1)
        expect(ex.abstract_method.name).to eq(:foo)
      end
    end

    context "class include B1 and implement" do
      it "does not raise" do
        class B3
          include B1

          def foo
          end
        end

        class B5 < B3
        end
      end
    end

    context "module include B1 and not implement" do
      it "raise Abstriker::NotImplementedError", aggregate_failures: true do
        ex = nil
        begin
          module B4
            include B1
          end
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
        expect(ex.subclass).to eq(B4)
        expect(ex.abstract_method.owner).to eq(B1)
        expect(ex.abstract_method.name).to eq(:foo)
      end
    end

    context "module include B1 and implement" do
      it "does not raise" do
        module B6
          include B1

          def foo
          end
        end

        class B9
          include B6
        end
      end
    end

    context "module include B1 (after) and implement" do
      it "does not raise" do
        module B7
          def foo
          end

          include B1
        end

        module B8
          include B7
        end
      end
    end

    context "Class.new include B1 and not implement" do
      it "raise Abstriker::NotImplementedError", aggregate_failures: true do
        ex = nil
        klass = nil
        begin
          Class.new do
            klass = self
            include B1
          end
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
        expect(ex.subclass).to eq(klass)
        expect(ex.abstract_method.owner).to eq(B1)
        expect(ex.abstract_method.name).to eq(:foo)
      end
    end

    context "Class.new include B1 and implement" do
      it "does not raise" do
        Class.new do
          include B1

          define_method(:foo) { }
        end
      end
    end

    context "Class.new include B1 (after) and implement" do
      it "does not raise" do
        Class.new do
          define_method(:foo) { }

          include B1
        end
      end
    end

    context "Class.new include B1 implement at parent class" do
      it "raise Abstriker::NotImplementedError", aggregate_failures: true do
        class B10
          def foo
          end
        end

        ex = nil
        klass = nil
        begin
          Class.new(B10) do
            klass = self
            include B1
          end
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
        expect(ex.subclass).to eq(klass)
        expect(ex.abstract_method.owner).to eq(B1)
        expect(ex.abstract_method.name).to eq(:foo)
      end
    end

    context "Class.new include B1 implement at prepended module" do
      it "does not raise", aggregate_failures: true do
        module B11
          def foo
          end
        end

        Class.new do
          include B1
          prepend B11
        end
      end
    end

    context "class extend B1 and not implement" do
      it "raise Abstriker::NotImplementedError", aggregate_failures: true do
        ex = nil
        begin
          class B13
            extend B1
          end
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
        expect(ex.subclass).to eq(B13)
        expect(ex.abstract_method.owner).to eq(B1)
        expect(ex.abstract_method.name).to eq(:foo)
      end
    end

    context "class extend B1 and implement" do
      it "does not raise" do
        class B14
          extend B1

          def self.foo
          end
        end

        class B15 < B14
        end
      end
    end

    context "Class.new extend B1 and not implement" do
      it "raise Abstriker::NotImplementedError", aggregate_failures: true do
        ex = nil
        klass = nil
        begin
          Class.new do
            klass = self
            extend B1
          end
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
        expect(ex.subclass).to eq(klass)
        expect(ex.abstract_method.owner).to eq(B1)
        expect(ex.abstract_method.name).to eq(:foo)
      end
    end

    context "Class.new extend B1 and implement" do
      it "does not raise" do
        klass = Class.new do
          def self.foo
          end

          extend B1
        end

        Class.new(klass) do
          class << self
            def foo
            end
          end
        end
      end
    end

    context "class << self include B1 and not implement" do
      it "raise Abstriker::NotImplementedError", aggregate_failures: true do
        ex = nil
        begin
          class B16
            class << self
              include B1
            end
          end
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
        expect(ex.subclass).to eq(B16.singleton_class)
        expect(ex.abstract_method.owner).to eq(B1)
        expect(ex.abstract_method.name).to eq(:foo)
      end
    end

    context "class << self include B1 and implement" do
      it "does not raise" do
        class B17
          class << self
            def foo
            end

            include B1
          end
        end

        class B18 < B17
        end
      end
    end

    context "Module.new include B1 and not implement" do
      it "raise Abstriker::NotImplementedError", aggregate_failures: true do
        ex = nil
        klass = nil
        begin
          Module.new do
            klass = self
            include B1
          end
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
        expect(ex.subclass).to eq(klass)
        expect(ex.abstract_method.owner).to eq(B1)
        expect(ex.abstract_method.name).to eq(:foo)
      end
    end

    context "Module.new include B1 and implement" do
      it "does not raise" do
        Module.new do
          include B1

          define_method(:foo) { }
        end
      end
    end

    context "Module.new include B1 (after) and implement" do
      it "does not raise" do
        Module.new do
          define_method(:foo) { }

          include B1
        end
      end
    end

    context "Module.new include B1 implement at prepended module" do
      it "does not raise", aggregate_failures: true do
        module B12
          def foo
          end
        end

        Module.new do
          include B1
          prepend B12
        end
      end
    end

    context "module extend B1 and not implement" do
      it "raise Abstriker::NotImplementedError", aggregate_failures: true do
        ex = nil
        begin
          module B19
            extend B1
          end
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
        expect(ex.subclass).to eq(B19)
        expect(ex.abstract_method.owner).to eq(B1)
        expect(ex.abstract_method.name).to eq(:foo)
      end
    end

    context "module extend B1 and implement" do
      it "does not raise" do
        module B20
          extend B1

          def self.foo
          end
        end
      end
    end

    context "Module.new extend B1 and not implement" do
      it "raise Abstriker::NotImplementedError", aggregate_failures: true do
        ex = nil
        klass = nil
        begin
          Module.new do
            klass = self
            extend B1
          end
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
        expect(ex.subclass).to eq(klass)
        expect(ex.abstract_method.owner).to eq(B1)
        expect(ex.abstract_method.name).to eq(:foo)
      end
    end

    context "Module.new extend B1 and implement" do
      it "does not raise" do
        Module.new do
          def self.foo
          end

          extend B1
        end
      end
    end

    context "class << self include B1 and not implement" do
      it "raise Abstriker::NotImplementedError", aggregate_failures: true do
        ex = nil
        begin
          module B21
            class << self
              include B1
            end
          end
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
        expect(ex.subclass).to eq(B21.singleton_class)
        expect(ex.abstract_method.owner).to eq(B1)
        expect(ex.abstract_method.name).to eq(:foo)
      end
    end

    context "class << self include B1 and implement" do
      it "does not raise" do
        module B22
          class << self
            def foo
            end

            include B1
          end
        end
      end
    end
  end

  context "D1 class has abstract singleton method" do
    before do
      class D1
        extend Abstriker

        abstract_singleton_method def self.foo
        end
      end
    end

    context "subclass not implement" do
      it "raise Abstriker::NotImplementedError", aggregate_failures: true do
        ex = nil
        begin
          class D2 < D1
          end
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
        expect(ex.subclass).to eq(D2)
        expect(ex.abstract_method.owner).to eq(D1.singleton_class)
        expect(ex.abstract_method.name).to eq(:foo)
      end
    end

    context "subclass implement" do
      it "does not raise" do
        class D3 < D1
          def self.foo
          end
        end

        class D5 < D3
        end

        class D6 < D1
          class << self
            def foo
            end
          end
        end
      end
    end

    context "Class.new(D1) and implement" do
      it "does not raise" do
        Class.new(D1) do
          pr = proc do
          end
          pr.call

          [1, 2, 3].each do |n|
            n * 2
          end

          class << self
            def foo
            end
          end
        end
      end
    end

    context "subclass and raise exception" do
      it "does raise the exception" do
        ex = nil
        begin
          class D4 < D1
            class << self
              raise "err"
            end
          end
        rescue => e
          ex = e
        end

        expect(ex).to be_a(RuntimeError)
      end
    end

    context "Class.new(D1) and raise exception" do
      it "does raise the exception" do
        ex = nil
        begin
          Class.new(D1) do
            class << self
              raise "err"
            end
          end
        rescue => e
          ex = e
        end

        expect(ex).to be_a(RuntimeError)
      end
    end

    context "Class.new(D1) with no block" do
      it "raise Abstriker::NotImplementedError" do
        ex = nil
        begin
          Class.new(D1)
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
      end
    end

    context "subclass include refined module that has implementation" do
      module D8
      end

      using Module.new {
        refine D8 do
          def foo
          end
        end
      }

      it "does not raise" do
        ex = nil
        begin
          class D7 < D1
            extend D8
          end
        rescue Abstriker::NotImplementedError => e
          ex = e
        end

        expect(ex).to be_a(Abstriker::NotImplementedError)
        expect(ex.subclass).to eq(D7)
        expect(ex.abstract_method.name).to eq(:foo)
        expect(D7.foo).to be_nil
      end
    end
  end

  context "complex pattern" do
    it do
      expect {
        module Foo
          extend Abstriker

          abstract def foo
          end
        end

        module Bar
          extend Abstriker

          abstract def bar
          end
        end

        c = Class.new do
          extend Foo

          self.include Foo
          include Bar

          def foo
          end
          alias :bar :foo

          def self.foo
          end
        end

        class Hoge < c
        end

        Module.new do
          include \
            Foo

          class_eval do
            extend Foo
          end

          def foo
          end

          def self.foo
          end
        end
      }.not_to raise_error

      ex = nil
      begin
        c = Class.new
        c.send(:include, Foo)
      rescue Abstriker::NotImplementedError => e
        ex = e
      end

      expect(ex).to be_a(Abstriker::NotImplementedError)
      expect(ex.abstract_method.name).to eq(:foo)

      ex = nil
      begin
        c = Class.new
        c.extend Foo
      rescue Abstriker::NotImplementedError => e
        ex = e
      end

      expect(ex).to be_a(Abstriker::NotImplementedError)
      expect(ex.abstract_method.name).to eq(:foo)
    end
  end

end
