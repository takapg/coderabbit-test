# frozen_string_literal: true

require 'rspec'
require_relative '../lib/sample'

RSpec.describe 'greet メソッドのテスト' do
  describe '挨拶 of 出力' do
    it '引数に渡した名前を含む挨拶を標準出力すること' do
      expect { greet('Alice') }.to output("Hello, Alice\n").to_stdout
    end

    it '名前がadminの場合、大文字で挨拶を標準出力すること' do
      expect { greet('admin') }.to output("HELLO, ADMIN\n").to_stdout
    end
  end

  describe '戻り値' do
    it '正しい結果（挨拶文字列）を返すこと' do
      expect(greet('Alice')).to eq 'Hello, Alice'
    end
  end
end
