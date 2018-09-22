require 'wierd_parser'
RSpec.describe WierdParser do
  subject { described_class.parse_string(input) }

  context "strings" do
    let(:input) { 'x="hello"' }
    it { is_expected.to eq(x: "hello") }
  end

  skip "strings with escaped characters" do
    let(:input) { 'x="hel\"lo"' }
    it { is_expected.to eq(x: 'hel"lo') }
  end

  context "identifiers" do
    let(:input) { "x=wabba" }
    it { is_expected.to eq(x: :wabba) }
  end

  context "integers" do
    let(:input) { "x=123" }
    it { is_expected.to eq(x: 123) }
  end

  context "floats" do
    let(:input) { "x=123.45" }
    it { is_expected.to eq(x: 123.45) }
  end

  context "normal hashes" do
    let(:input) { <<~END_INPUT }
      x={
        type=programmer
        "something else"=5}
    END_INPUT

    it { is_expected.to eq(x: { type: :programmer, "something else" => 5 }) }
  end

  context "wierd single value hashes" do
    let(:input) { "x = {\n5}" }
    it { is_expected.to eq(x: 5) }
  end

  context "the whole given example" do
    let(:input) { <<~END_INPUT }
      employees={
        Bill={
          type=programmer
          fullname="Bill Billiams"
          skills={
            programmer=5
            talking="okay"
          }
          salary={
      105.44}
          }
        Jess={
          type="human resources"
          fullname="Jessica Rabit"
          skills={
            language="french"
            talking="hard to understand"
          }
          salary={
      96.4}
        }
        facilities={
          hq="Seattle"}
        "something else"={
          type=fishsticks
        } 
      }
    END_INPUT

    it 'works' do
      is_expected.to eq({
        employees: {
          Bill: {
            type: :programmer,
            fullname: 'Bill Billiams',
            skills: {
              programmer: 5,
              talking: 'okay',
            },
            salary: 105.44,
          },
          Jess: {
            type: "human resources",
            fullname: 'Jessica Rabit',
            skills: {
              language: 'french',
              talking: 'hard to understand',
            },
            salary: 96.4,
          },
          facilities: {
            hq: 'Seattle',
          },
          'something else' => {
            type: :fishsticks,
          },
        }
      })
    end
  end
end

