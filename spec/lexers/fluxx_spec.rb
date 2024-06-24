# -*- coding: utf-8 -*- #
# frozen_string_literal: true

describe Rouge::Lexers::Fluxx do
  let(:subject) { Rouge::Lexers::Fluxx.new }
  let(:bom) { "\xEF\xBB\xBF" }

  describe 'guessing' do
    include Support::Guessing

    it 'guesses by filename' do
      assert_guess :filename => 'foo.fluxx'
      assert_guess :filename => 'foo.fx'
    end

    it 'guesses by source' do
      assert_guess :source => '<?fluxx version="1.0" encoding="utf-8"?>'
      assert_guess :source => %{#{bom}<?fluxx version="1.0" encoding="utf-8"?>}
      assert_guess :source => '<?fluxx version="1.0" ?><element prop1=42 />'
    end
  end
end
