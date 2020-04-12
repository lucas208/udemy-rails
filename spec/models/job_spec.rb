require 'rails_helper'

RSpec.describe Job, type: :model do
  
  let(:job) { build (:job) }

  context 'When is new' do
    it { expect(job).not_to be_done }
  end

  it { is_expected.to belong_to(:user)}

  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :user_id }
  
  it { is_expected.to respond_to(:title)}
  it { is_expected.to respond_to(:description)}
  it { is_expected.to respond_to(:deadline)}
  it { is_expected.to respond_to(:done)}
  it { is_expected.to respond_to(:user_id)}


end
