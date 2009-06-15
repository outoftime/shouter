module Shouter
  class ActorsCache
    class <<self
      def generate(actors)
        new(actors || []).to_s
      end
    end

    def initialize(actors)
      @actors = actors
    end

    def to_s
      @to_s ||=
        begin
          actors =
            if @actors.respond_to?(:map)
              @actors
            else
              [@actors]
            end
          actors.map do |author|
            "#{author.class.base_class.name}:#{author.id}"
          end.sort.join(' ')
        end
    end
  end
end
