RSpec.describe ActiveRecord::SqlAnalyzer::RedactedLogger do
  let(:tmp_dir) { Dir.mktmpdir }
  after { FileUtils.remove_entry(tmp_dir) }

  context "#filter_event" do
    let(:event) { {} }

    subject(:filter_event) do
      instance = described_class.new(tmp_dir, "foo")
      instance.filter_event(event)
      event
    end

    before do
      ActiveRecord::SqlAnalyzer.configure do |c|
        c.add_backtrace_redactors [
          [/erb_erb_[0-9]+_[0-9]+/, ""]
        ]
      end
    end

    context "ambiguous backtraces" do
      let(:event) do
        {
          caller: %w(ambiguous foo bar),
          sql: ""
        }
      end

      before do
        ActiveRecord::SqlAnalyzer.configure do |c|
          c.add_ambiguous_tracers [/ambiguous/]
        end
      end

      it "switches to ambiguous backtrace logging" do
        expect(filter_event[:caller]).to eq("ambiguous, foo, bar")
      end
    end

    context "backtrace" do
      let(:event) do
        {
          caller: %w(foo-bar-erb_erb_1_5),
          sql: ""
        }
      end

      it "redacts" do
        expect(filter_event[:caller]).to eq("foo-bar-")
      end
    end

    context "sql quoted" do
      let(:event) do
        {
          caller: [""],
          sql: "SELECT * FROM foo WHERE name = 'hello\\'s name'"
        }
      end

      it "redacts" do
        expect(filter_event[:sql]).to eq("SELECT * FROM foo WHERE name = '[REDACTED]'")
      end
    end

    context "sql quoted multiple WHERE" do
      let(:event) do
        {
          caller: [""],
          sql: "SELECT * FROM foo WHERE name = 'hello\\'s name' AND age = '21'"
        }
      end

      it "redacts" do
        expect(filter_event[:sql]).to eq("SELECT * FROM foo WHERE name = '[REDACTED]' AND age = '[REDACTED]'")
      end
    end


    context "sql escaped and quoted" do
      let(:event) do
        {
          caller: [""],
          sql: "SELECT * FROM foo WHERE name = 'hello\\\'s name'"
        }
      end

      it "redacts" do
        expect(filter_event[:sql]).to eq("SELECT * FROM foo WHERE name = '[REDACTED]'")
      end
    end

    context "sql case insensitivity" do
      let(:event) do
        {
          caller: [""],
          sql: "SELECT * FROM foo WHERE name lIkE 'hello'"
        }
      end

      it "redacts" do
        expect(filter_event[:sql]).to eq("SELECT * FROM foo WHERE name LIKE '[REDACTED]'")
      end      
    end

    context "sql" do
      let(:event) do
        {
          caller: [""],
          sql: "SELECT * FROM foo WHERE id = 1234"
        }
      end

      it "redacts" do
        expect(filter_event[:sql]).to eq("SELECT * FROM foo WHERE id = [REDACTED]")
      end
    end

    context "like quoted" do
      let(:event) do
        {
          caller: [""],
          sql: "SELECT * FROM foo WHERE name LIKE 'A \\'quoted\\' value.'"
        }
      end

      it "redacts" do
        expect(filter_event[:sql]).to eq("SELECT * FROM foo WHERE name LIKE '[REDACTED]'")
      end
    end

    context "like escaped and quoted" do
      let(:event) do
        {
          caller: [""],
          sql: "SELECT * FROM foo WHERE name LIKE 'A \\\'quoted\\\' value.'"
        }
      end

      it "redacts" do
        expect(filter_event[:sql]).to eq("SELECT * FROM foo WHERE name LIKE '[REDACTED]'")
      end
    end

    context "in quoted" do
      let(:event) do
        {
          caller: [""],
          sql: "SELECT * FROM foo WHERE name IN ('A \\'quoted\\' value.')"
        }
      end

      it "redacts" do
        expect(filter_event[:sql]).to eq("SELECT * FROM foo WHERE name IN ([REDACTED])")
      end
    end

    context "in escaped and quoted" do
      let(:event) do
        {
          caller: [""],
          sql: "SELECT * FROM foo WHERE name IN ('A \\\'quoted\\\' value.')"
        }
      end

      it "redacts" do
        expect(filter_event[:sql]).to eq("SELECT * FROM foo WHERE name IN ([REDACTED])")
      end
    end

    context "between quoted" do
      let(:event) do
        {
          caller: [""],
          sql: "SELECT * FROM foo WHERE name BETWEEN 'A \\'quoted\\' value.' AND 'Another value'"
        }
      end

      it "redacts" do
        expect(filter_event[:sql]).to eq("SELECT * FROM foo WHERE name BETWEEN '[REDACTED]' AND '[REDACTED]'")
      end
    end

    context "between escaped and quoted" do
      let(:event) do
        {
          caller: [""],
          sql: "SELECT * FROM foo WHERE name BETWEEN 'A \\\'quoted\\\' value.' AND 'Another value'"
        }
      end

      it "redacts" do
        expect(filter_event[:sql]).to eq("SELECT * FROM foo WHERE name BETWEEN '[REDACTED]' AND '[REDACTED]'")
      end
    end
  end
end
