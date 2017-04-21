class Ghee

  # API module encapsulates all of API endpoints
  # implemented thus far
  #
  module API

    # The Repos module handles all of the Github Repo
    # API endpoints
    #
    module Repos

      module Pulls
        class Proxy < ::Ghee::ResourceProxy
          include Ghee::CUD

          def commits
            connection.get("#{path_prefix}/commits").body
          end

          def files
            connection.get("#{path_prefix}/files").body
          end

          def merge?
            connection.get("#{path_prefix}/merge").status == 204
          end

          def merge!(message=nil)
            params = message ? {:commit_message=>message} : {}
            connection.put("#{path_prefix}/merge", params).body
          end

          def reviews(id = nil)
            prefix = id ? "#{path_prefix}/reviews/#{id}" : "#{path_prefix}/reviews"
            Ghee::API::Repos::Pulls::Reviews::Proxy.new(connection, prefix)
          end
        end

        module Reviews
          class Proxy < ::Ghee::ResourceProxy
            accept_header 'application/vnd.github.black-cat-preview+json'

            undef_method :create
            undef_method :destroy
            undef_method :patch
          end
        end
      end

      # Gists::Proxy inherits from Ghee::Proxy and
      # enables defining methods on the proxy object
      #
      class Proxy < ::Ghee::ResourceProxy
        def pulls(number=nil, params={})
          params = number if number.is_a?Hash
          prefix = (!number.is_a?(Hash) and number) ? "#{path_prefix}/pulls/#{number}" : "#{path_prefix}/pulls"
          Ghee::API::Repos::Pulls::Proxy.new(connection, prefix, params)
        end
      end
    end
  end
end

