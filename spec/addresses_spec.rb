# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe "SendGrid4r::REST::Ips::Addresses" do

  before :all do
    Dotenv.load
  end

  context "if account is free" do
    before :all do
      @client = SendGrid4r::Client.new(ENV["SENDGRID_USERNAME"], ENV["SENDGRID_PASSWORD"])
    end

    describe "#get_ips" do
      it "raise error" do
        expect{@client.get_ips}.to raise_error(RestClient::Forbidden)
      end
    end

    describe "#get_ip" do
      it "raise error" do
        expect{@client.get_ip("10.10.10.10").to raise_error(RestClient::Forbidden)}
      end
    end
  end

  context "if account is silver" do
    TEST_POOL = "test_pool"
    before :all do
      @client = SendGrid4r::Client.new(ENV["SILVER_SENDGRID_USERNAME"], ENV["SILVER_SENDGRID_PASSWORD"])
      # refresh the pool
      pools = @client.get_pools
      pools.each {|pool|
        @client.delete_pool(TEST_POOL) if pool == TEST_POOL
      }
      @client.post_pool(TEST_POOL)
      #ips = @client.get_ips
      #@client.delete_ip_from_pool(TEST_POOL, ips[0].ip)
    end

    describe "#get_ips" do
      it "returns Array of Address instance" do
        ips = @client.get_ips
        expect(ips.length > 0).to be(true)
        expect(ips[0].class).to be(SendGrid4r::REST::Ips::Address)
      end
    end

    describe "#get_ip" do
      it "returns Address instance" do
        ips = @client.get_ips
        expect(@client.get_ip(ips[0].ip).class).to be(SendGrid4r::REST::Ips::Address)
      end
    end

    describe "#post_ip_to_pool" do
      it "add ip to pool successfully" do
        ips = @client.get_ips
        actual = @client.post_ip_to_pool(TEST_POOL, ips[0].ip)
        expect(actual.ip).to eq(ips[0].ip)
        expect(actual.pool_name).to eq(TEST_POOL)
      end
    end

    # Could not test because POST an IP to a pool takes 60 sec
    # describe "#delete_ip_from_pool" do
    #   it "delete ip from pool successfully" do
    #     begin
    #       ips = @client.get_ips
    #       @client.post_ip_to_pool(TEST_POOL, ips[0].ip)
    #       @client.delete_ip_from_pool(TEST_POOL, ips[0].ip)
    #     rescue => e
    #       puts e.inspect
    #       raise e
    #     end
    #   end
    # end
  end
end
