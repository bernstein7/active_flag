require 'test_helper'

class ActiveFlagTest < Minitest::Test
  def setup
    @profile = Profile.new
    @profile.languages.set(:english)
  end

  def test_predicate
    assert @profile.languages.english?
    refute @profile.languages.chinese?
  end

  def test_set_and_unset
    @profile.languages.set(:chinese)
    assert @profile.languages.chinese?

    @profile.languages.unset(:chinese)
    refute @profile.languages.chinese?
  end

  def test_raw
    assert_equal @profile.languages.raw, 1
    @profile.languages.set(:spanish)
    assert_equal @profile.languages.raw, 3
    @profile.languages.set(:chinese)
    assert_equal @profile.languages.raw, 7
  end

  def test_locale
    @profile.languages.set(:spanish)

    I18n.locale = :ja
    assert_equal ['英語', 'スペイン語'], @profile.languages.to_human

    I18n.locale = :en
    assert_equal ['English', 'Spanish'], @profile.languages.to_human
  end
end