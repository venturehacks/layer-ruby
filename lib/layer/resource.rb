module Layer
  class Resource

    class << self
      attr_writer :client

      def class_name
        name.split('::')[-1]
      end

      def url
        "/#{class_name.downcase.to_s}s"
      end

      def from_response(attributes, client)
        new(attributes, client)
      end

      def client
        @client ||= Client::Platform.new
      end
    end

    attr_accessor :client, :attributes

    def initialize(attributes = {}, client = self.class.client)
      self.attributes = attributes
      self.client = client
    end

    def url
      attributes['url'] || (id && "#{self.class.url}/#{Layer::Client.normalize_id(id)}")
    end

    def id
      attributes['id']
    end

    def respond_to_missing?(method, include_private = false)
      attribute = method.to_s.sub(/=$/, '')

      attributes.has_key?(attribute) || super
    end

  private

    def method_missing(method, *args, &block)
      if method.to_s =~ /=$/
        attribute = method.to_s.sub(/=$/, '')
        attributes[attribute] = args.first
      elsif attributes.has_key?(method.to_s)
        attributes[method.to_s]
      else
        super
      end
    end

  end
end
