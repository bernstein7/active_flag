require 'test_helper'

class ActiveFlagTest < Minitest::Test
  def setup
    @profile = Profile.first
  end

  def test_predicate
    assert @profile.languages.english?
    refute @profile.languages.chinese?
  end

  def test_set_and_unset?
    assert @profile.languages.set?(:english)
    assert @profile.languages.unset?(:chinese)
  end

  def test_set_and_unset_strings?
    assert @profile.features.set?(Features::EMAILS)
    assert @profile.features.unset?(Features::STREAMING)
  end

  def test_set_and_unset
    @profile.languages.set(:chinese)
    assert @profile.languages.chinese?

    @profile.languages.unset(:chinese)
    refute @profile.languages.chinese?
  end

  def test_set_and_unset_strings
    @profile.features.set(Features::STREAMING)
    assert @profile.features.set?(Features::STREAMING)

    @profile.features.unset(Features::STREAMING)
    refute @profile.features.set?(Features::STREAMING)
  end

  def test_set_and_unset!
    @profile.languages.set!(:chinese)
    assert Profile.first.languages.chinese?

    @profile.languages.unset!(:chinese)
    refute Profile.first.languages.chinese?
  end

  def test_direct_symbol_assign
    @profile.languages = [:french, :japanese]
    assert @profile.languages.french?
    assert @profile.languages.japanese?
  end

  def test_string_assign
    @profile.features = [Features::STREAMING, Features::AUTOMATION]
    assert @profile.features.set?(Features::STREAMING)
    assert @profile.features.set?(Features::AUTOMATION)
  end

  def test_direct_assign_nil
    @profile.figures = [:square, :circle]
    assert @profile.figures.square?
    assert @profile.figures.circle?
  end

  def test_default_empty_array
    @profile.languages = []

    assert_equal @profile.languages.raw, 0
    assert @profile.languages, 0
  end

  def test_default_nil
    assert_equal @profile.figures.raw, 0
    assert @profile.figures, 0
  end

  def test_direct_string_assign
    @profile.languages = ['french', 'japanese']
    assert @profile.languages.french?
    assert @profile.languages.japanese?
  end

  def test_duplicate_direct_assign
    @profile.languages = [:spanish, :spanish]
    assert @profile.languages.spanish?
    refute @profile.languages.chinese?
  end

  def test_raw
    assert_equal @profile.languages.raw, 1

    @profile.languages.set(:spanish)
    assert_equal @profile.languages.raw, 3

    @profile.languages.set(:chinese)
    assert_equal @profile.languages.raw, 7

    @profile.features.set(Features::AUTOMATION)
    assert_equal @profile.features.raw, 5
  end

  def test_to_s
    assert_equal @profile.languages.to_s, '[:english]'
  end

  def test_locale
    @profile.languages.set(:spanish)

    I18n.locale = :ja
    assert_equal ['英語', 'スペイン語'], @profile.languages.to_human

    I18n.locale = :en
    assert_equal ['English', 'Spanish'], @profile.languages.to_human
  end

  def test_set_all_and_unset_all
    Profile.languages.set_all!(:chinese)
    assert Profile.first.languages.chinese?

    Profile.features.set_all!(Features::STREAMING)
    assert Profile.first.features.set?(Features::STREAMING)

    Profile.languages.unset_all!(:chinese)
    refute Profile.first.languages.chinese?

    Profile.features.unset_all!(Features::STREAMING)
    refute Profile.first.features.set?(Features::STREAMING)
  end

  def test_multiple_flags
    assert Profile.languages
    assert Profile.others
  end

  def test_subclass
    assert_equal SubProfile.languages.keys, Profile.languages.keys
    assert_raises { SubProfile.flag :languages, [:english] }
  end

  def test_same_column_in_other_class
    assert_equal Profile.others.keys, [:thing]
    assert_equal Other.others.keys, [:another]
  end

  def test_scope
    assert_equal Profile.where_languages(:english).count, 2
    assert_equal Profile.where_languages(:japanese).count, 2
    assert_equal Profile.where_languages(:english, :japanese).count, 3
    ActiveSupport::Deprecation.silence do
      assert_equal Profile.where_languages(:english, :japanese, op: :and).count, 1
    end
    assert_equal Profile.where_all_languages(:english, :japanese).count, 1
    assert_equal Profile.where_not_languages(:english).count, 1
    assert_equal Profile.where_not_languages(:english, :japanese).count, 0
    assert_equal Profile.where_not_all_languages(:english, :japanese).count, 2
    assert_equal Profile.where_not_languages(:chinese).count, 3
    assert_equal Profile.where_not_all_languages(:chinese).count, 3
    assert_equal Profile.where_features(Features::EMAILS, Features::STREAMING).count, 2
    assert_equal Profile.where_features(Features::AUTOMATION).count, 0
    assert_equal Profile.where_not_features(Features::AUTOMATION).count, 3
  end
end
