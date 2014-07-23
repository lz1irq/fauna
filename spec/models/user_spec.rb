# -*- coding: utf-8 -*-
require 'rails_helper'

describe User do
  it 'checks if the name is present' do
    expect(build(:user, name: nil)).to have_error_on :name
  end

  it 'checks if the username is present' do
    expect(build(:user, username: nil)).to have_error_on :username
  end

  describe '::find_for_database_authentication' do
    let(:user) { create :user }

    it 'return user when email is passed' do
      expect(User.find_for_database_authentication login: user.email).not_to be_nil
    end

    it 'return user when username is passed' do
      expect(User.find_for_database_authentication login: user.username).not_to be_nil
    end

    it 'return nil when login is not existing' do
      expect(User.find_for_database_authentication login: "randomuser").to be_nil
    end

    it 'return nil when login is nil' do
      expect(User.find_for_database_authentication login: "randomuser").to be_nil
    end

    it 'return nil when login is omitted' do
      expect(User.find_for_database_authentication Hash.new).to be_nil
    end
  end

  describe 'username' do
    it 'must be present' do
      expect(build(:user, username: nil)).to have_error_on :username
    end

    it 'must be at least one character' do
      expect(build(:user, username: '')).to have_error_on :username
    end

    it 'must be unique' do
      existing_user = create :user

      expect(build(:user, username: existing_user.username)).to have_error_on :username
    end

    it 'must only contain letters, numbers, _ and -' do
      invalid_usernames = %w(ji*r3f пешо +vlado)

      invalid_usernames.each do |username|
        expect(build(:user, username: username)).to have_error_on :username
      end
    end
  end

  describe '#destroy' do
    let(:user) { create :user }

    before do
      create :network_device, owner: user
    end

    it 'destroys dependent Computers' do
      network_device = user.network_devices.first
      user.destroy
      expect { NetworkDevice.find network_device.id }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe 'url' do
    let(:valid_urls) { %w(http://foo.bar https://foo.bar)}
    let(:invalid_urls) { %w(javascript:alert(foo.bar) mailto:)}

    it 'can be nil' do
      expect(build(:user, url: nil)).to_not have_error_on :url
      expect(build(:user, url: '')).to_not have_error_on :url
    end

    it 'can be an HTTP URL' do
      expect(build(:user, url: 'http://example.com')).to_not have_error_on :url
    end

    it 'can be an HTTPS URL' do
      expect(build(:user, url: 'https://example.com')).to_not have_error_on :url
    end

    it 'cannot be anything but an HTTP(S) URL' do
      expect(build(:user, url: 'javascript:alert(foo)')).to have_error_on :url
      expect(build(:user, url: 'example.com')).to have_error_on :url
      expect(build(:user, url: 'foobar')).to have_error_on :url
    end
  end

  describe 'twitter handle' do
    let(:valid_handles) { %w(f F 1 _ foo fOO FOO f_oo f00) }
    let(:invalid_handles) { %w(- абв abcdefghijklmnopqrst) }

    it 'is stored without a starting @' do
      expect(build(:user, twitter: '@foobar').twitter).to eq 'foobar'
    end

    it 'can be nil' do
      expect(build(:user, twitter: nil)).to_not have_error_on :twitter
    end

    it 'can be a valid handle' do
      valid_handles.each do |handle|
        expect(build(:user, twitter: handle)).to_not have_error_on :twitter
      end
    end

    it 'cannot be an invalid handle' do
      invalid_handles.each do |handle|
        expect(build(:user, twitter: handle)).to have_error_on :twitter
      end
    end
  end
end
