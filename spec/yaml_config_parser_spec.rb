require 'spec_helper'

describe Jasmine::YamlConfigParser do
  it "spec_helper returns default helper path when spec_helper is blank" do
    yaml_loader = lambda do |path|
      if path == "some_path"
        {"spec_helper" => nil}
      end
    end
    parser = Jasmine::YamlConfigParser.new('some_path', 'some_project_root', nil, yaml_loader)
    expect(parser.spec_helper).to eq 'some_project_root/spec/javascripts/support/jasmine_helper.rb'
  end

  it "spec_helper returns spec_helper if set" do
    yaml_loader = lambda do |path|
      if path == "some_path"
        {"spec_helper" => 'some_spec_helper.rb'}
      end
    end
    parser = Jasmine::YamlConfigParser.new('some_path', 'some_project_root', nil, yaml_loader)
    expect(parser.spec_helper).to eq 'some_project_root/some_spec_helper.rb'
  end

  it "random returns random if set" do
    yaml_loader = lambda do |path|
      if path == "some_path"
        {"random" => true}
      end
    end
    parser = Jasmine::YamlConfigParser.new('some_path', 'some_project_root', nil, yaml_loader)
    expect(parser.random).to eq true
  end

  it "random defaults to true" do
    yaml_loader = lambda do |path|
      if path == "some_path"
        {"random" => nil}
      end
    end
    parser = Jasmine::YamlConfigParser.new('some_path', 'some_project_root', nil, yaml_loader)
    expect(parser.random).to eq true
  end
end

