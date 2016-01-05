require 'spec_helper'

describe Layer::Conversation do

  let(:client) { instance_double("Layer::Client") }
  let(:response) do
    {
      'url' => 'https://api.layer.com/apps/default_app_id/conversations/conversation_id',
      'participants' => ['1', '2'],
      'id' => 'layer:///conversations/conversation_id',
      'distinct' => false,
      'metadata' => { 'foo' => 'bar' },
      'created_at' => '2015-06-19T08:00:00.000Z'
    }
  end

  subject { described_class.from_response(response, client) }

  describe '.find' do
    before do
      allow(client).to receive(:get).and_return(response)
    end

    it 'should load the conversation' do
      described_class.find('1', client)
      expect(client).to have_received(:get).with("/conversations/1")
    end

    it 'should work with the full id format' do
      described_class.find('layer:///conversations/conversation_id', client)
      expect(client).to have_received(:get).with("/conversations/conversation_id")
    end

    it 'should return an instace' do
      expect(described_class.find('1', client))
        .to be_kind_of(described_class)
    end
  end

  describe '.create' do
    let(:attributes) do
      {
        'participants' => ['1', '2'],
        'metadata' => { 'foo' => 'bar' }
      }
    end

    before do
      allow(client).to receive(:post).and_return(response)
    end

    it 'should create the conversation' do
      described_class.create(attributes, client)
      expect(client).to have_received(:post).with("/conversations", attributes)
    end

    it 'should return an instace' do
      expect(described_class.create(attributes, client))
        .to be_kind_of(described_class)
    end
  end

  describe '#reload' do
    before do
      allow(client).to receive(:get).and_return(response)
    end

    it 'should reload the data from the server' do
      subject.reload
      expect(client).to have_received(:get).with(subject.url)
    end

    it 'should return itself' do
      expect(subject.reload).to be(subject)
    end
  end

  describe '#save' do
    before do
      allow(client).to receive(:patch).and_return(response)
    end

    it 'should update the changes on the server' do
      subject.participants << '3'
      subject.metadata[:foo] = 'bar'
      subject.save

      expect(client).to have_received(:patch).with(subject.url, [
        { operation: 'add', property: 'participants', value: '3'},
        { operation: 'set', property: 'metadata.foo', value: 'bar' }
      ])
    end
  end

  describe '#delete' do
    it 'should delete the conversation' do
      expect(client).to receive(:delete).with(subject.url)
      subject.delete
    end
  end

  describe '#destroy' do
    it 'should destroy the conversation' do
      expect(client).to receive(:delete).with(subject.url, {}, { params: { destroy: true } })
      subject.destroy
    end
  end

  describe '#messages' do
    it 'should return an relation proxy' do
      expect(subject.messages).to be_kind_of(Layer::RelationProxy)
    end

    it 'should have Message as resource_type' do
      expect(subject.messages.resource_type).to eq(Layer::Message)
    end

    it 'should support the create operation' do
      expect(subject.messages).to be_kind_of(Layer::Operations::Create::ClassMethods)
    end
  end

  describe '#distinct?' do
    context 'when the attribute is true' do
      before { response['distinct'] = true }

      it 'should be distinct' do
        expect(subject).to be_distinct
      end
    end

    context 'when the attribute is false' do
      before { response['distinct'] = false }

      it 'should not be distinct' do
        expect(subject).to_not be_distinct
      end
    end
  end

  describe '#created_at' do
    it 'should return the time the conversation was created at' do
      expect(subject.created_at).to eq(Time.utc(2015, 06, 19, 8, 0, 0))
    end
  end

end
