RSpec.describe Abstriker do
  context "abstract method is not implemented by subclass" do
    it "raise Abstriker::NotImplementedError", aggregate_failures: true do
      ex = nil
      begin
        class A1
          extend Abstriker

          abstract def foo
          end
        end

        class A2 < A1
        end
      rescue Abstriker::NotImplementedError => e
        ex = e
      end

      class A3 < A1
        def foo
        end
      end

      class A5 < A3
      end

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

      expect(ex).to be_a(Abstriker::NotImplementedError)
      expect(ex.subclass).to eq(A2)
      expect(ex.abstract_method.owner).to eq(A1)
      expect(ex.abstract_method.name).to eq(:foo)

      ex = nil
      begin
        class A4 < A1
          raise "err"

          def foo
          end
        end
      rescue => e
        ex = nil
      end

      expect(e).to be_a(RuntimeError)

      ex = nil
      begin
        Class.new(A1) do
          raise "err"

          def foo
          end
        end
      rescue => e
        ex = nil
      end

      expect(e).to be_a(RuntimeError)
    end
  end

  context "abstract method is not implemented by include class" do
    it "raise Abstriker::NotImplementedError", aggregate_failures: true do
      ex = nil
      begin
        module B1
          extend Abstriker

          abstract def foo
          end
        end

        class B2
          include B1
        end
      rescue Abstriker::NotImplementedError => e
        ex = e
      end

      class B3
        include B1

        def foo
        end
      end

      module B4
        def foo
        end

        include B1
      end

      class B5 < B3
      end

      module B6
        include B4
      end

      Module.new do
        include B1

        pr = proc { }
        pr.call

        def foo
        end
      end

      expect(ex).to be_a(Abstriker::NotImplementedError)
      expect(ex.subclass).to eq(B2)
      expect(ex.abstract_method.owner).to eq(B1)
      expect(ex.abstract_method.name).to eq(:foo)
    end
  end

  context "abstract method is not implemented by extend class" do
    it "raise Abstriker::NotImplementedError", aggregate_failures: true do
      ex = nil
      begin
        module C1
          extend Abstriker

          abstract def foo
          end
        end

        class C2
          extend C1
        end
      rescue Abstriker::NotImplementedError => e
        ex = e
      end

      class C3
        extend C1

        def self.foo
        end
      end

      class C4
        class << self
          def foo
          end
        end

        extend C1
      end

      Module.new do
        pr = proc {}
        pr.call

        def self.foo
        end

        extend C1
      end

      expect(ex).to be_a(Abstriker::NotImplementedError)
      expect(ex.subclass).to eq(C2)
      expect(ex.abstract_method.owner).to eq(C1)
      expect(ex.abstract_method.name).to eq(:foo)
    end
  end

  context "abstract singleton method is not implemented by subclass" do
    it "raise Abstriker::NotImplementedError", aggregate_failures: true do
      ex = nil
      begin
        class D1
          extend Abstriker

          class << self
            abstract def foo
            end
          end
        end

        class D2 < D1
        end
      rescue Abstriker::NotImplementedError => e
        ex = e
      end

      class D3 < D1
        def self.foo
        end
      end

      Class.new(D1) do
        pr = proc {}
        pr.call

        def self.foo
        end
      end

      expect(ex).to be_a(Abstriker::NotImplementedError)
      expect(ex.subclass).to eq(D2)
      expect(ex.abstract_method.owner).to eq(D1.singleton_class)
      expect(ex.abstract_method.name).to eq(:foo)
    end
  end

  context "Abstriker.disable = true" do
    context "abstract method is not implemented by subclass" do
      around do |ex|
        Abstriker.disable = true
        ex.call
        Abstriker.disable = false
      end

      it "does not raise", aggregate_failures: true do
        class E1
          extend Abstriker

          abstract def foo
          end
        end

        class E2 < E1
        end

        class E3 < E1
          def foo
          end
        end
      end
    end
  end
end
