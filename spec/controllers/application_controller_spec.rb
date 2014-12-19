require 'spec_helper'

describe ApplicationController do

  describe "#repositories" do
    subject(:repositories) { controller.repositories }
    it { should be_instance_of(HashWithIndifferentAccess) }

    context "when repository is Fales" do
      subject(:repository) { repositories[:fales] }
      it { expect(repository[:display]).to eql("The Fales Library & Special Collections") }
      it { expect(repository[:url]).to eql("fales") }
      it { expect(repository[:admin_code]).to eql("fales") }
    end

    context "when repository is Tamiment " do
      subject(:repository) { repositories[:tamiment] }
      it { expect(repository[:display]).to eql("The Tamiment Library & Robert F. Wagner Labor Archives") }
      it { expect(repository[:url]).to eql("tamiment") }
      it { expect(repository[:admin_code]).to eql("tamiment") }
    end

    context "when repository is NYU Archives " do
      subject(:repository) { repositories[:universityarchives] }
      it { expect(repository[:display]).to eql("New York University Archives") }
      it { expect(repository[:url]).to eql("universityarchives") }
      it { expect(repository[:admin_code]).to eql("universityarchives") }
    end

    context "when repository is NYHS" do
      subject(:repository) { repositories[:nyhistory] }
      it { expect(repository[:display]).to eql("New-York Historical Society") }
      it { expect(repository[:url]).to eql("nyhistory") }
      it { expect(repository[:admin_code]).to eql("nyhistory") }
    end

    context "when repository is BHS" do
      subject(:repository) { repositories[:brooklynhistory] }
      it { expect(repository[:display]).to eql("Brooklyn Historical Society") }
      it { expect(repository[:url]).to eql("brooklynhistory") }
      it { expect(repository[:admin_code]).to eql("brooklynhistory") }
    end

    context "when repository is Poly Archives" do
      subject(:repository) { repositories[:poly] }
      it { expect(repository[:display]).to eql("Poly Archives") }
      it { expect(repository[:url]).to eql("poly") }
      it { expect(repository[:admin_code]).to eql("poly") }
    end

    context "when repository is RISM" do
      subject(:repository) { repositories[:rism] }
      it { expect(repository[:display]).to eql("Research Institue for the Study of Man") }
      it { expect(repository[:url]).to eql("rism") }
      it { expect(repository[:admin_code]).to eql("rism") }
    end

  end

  describe "#current_user_dev" do
    subject(:user) { controller.current_user_dev }
    it { should be_instance_of(User) }
    it { expect(user.username).to eql("admin123") }
  end

end
