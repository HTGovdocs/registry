include Registry::Series
Series = Registry::Series
describe "Series.calc_end_year" do
  it "handles simple 3 digit years" do
    expect(Series.calc_end_year("1995", "998")).to eq("1998")
  end

  it "handles simple 2 digit years" do
    expect(Series.calc_end_year("1995", "98")).to eq("1998")
  end

  it "handles 3 character rollovers" do
    expect(Series.calc_end_year("1999", "002")).to eq("2002")
  end

  it "handles 2 character rollovers" do
    expect(Series.calc_end_year("1999", "02")).to eq("2002")
  end

end

describe "Series.lookup_month" do
  it "returns August for aug" do
    expect(Series.lookup_month('aug.')).to eq('August')
  end

  it "returns June for JE." do
    expect(Series.lookup_month('JE.')).to eq('June')
  end
end

describe "Series.correct_year" do
  it "handles 21st century" do 
    expect(Series.correct_year("005")).to eq('2005')
  end

  it "handles 19th centruy" do
    expect(Series.correct_year(895)).to eq('1895')
  end

  # todo: not entirely sure what we should do with these.
  # Should we return nil?
  it "handles bogus centuries" do
    expect(Series.correct_year(650)).to eq('2650')
  end
end

describe "all Series" do
  Registry::Series.constants.select { |c| eval(c.to_s).class == Module }.each do |c|
    s = Class.new { extend eval(c.to_s) }
    it "the canonicalize method returns nil if {} given" do
      puts c
      expect(s.respond_to?(:canonicalize)).to be_truthy
      expect(s.canonicalize({})).to be_nil
    end

    it "fails to explode if it can't canonicalize" do
      expect(s.respond_to?(:explode)).to be_truthy
      expect(s.explode({'string'=>"cant_canonicalize_this"}).keys.count).to eq(0)
    end
  end
end


