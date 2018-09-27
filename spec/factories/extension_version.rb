FactoryBot.define do
  factory :extension_version do
    association :extension, extension_versions_count: 0

    description { 'An awesome extension!' }
    license { 'MIT' }
    sequence(:version) { |n| "1.2.#{n}" }
    readme { '# redis extension' }
    readme_extension { 'md' }
    foodcritic_failure { false }
  end
end
