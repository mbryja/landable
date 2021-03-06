require_dependency 'landable/api_controller'

module Landable
  module Api
    class AccessTokensController < ApiController
      skip_before_filter :require_author!, only: [:create]

      def show
        respond_with find_own_access_token
      end

      def create
        ident  = AuthenticationService.call(asset_token_params[:username], asset_token_params[:password])

        author = RegistrationService.call(ident)

        permissions = determine_permissions(ident[:groups])

        respond_with AccessToken.create!(author: author, permissions: permissions), status: :created
      rescue Landable::AuthenticationFailedError
        head :unauthorized
      end

      def update
        token = find_own_access_token
        token.refresh!

        respond_with token
      end

      def destroy
        token = find_own_access_token
        token.destroy!
        head :no_content
      rescue ActiveRecord::RecordNotFound
        head :unauthorized
      end

      private

      def find_own_access_token(id = params[:id])
        current_author.access_tokens.fresh.find(id)
      end

      def asset_token_params
        params.require(:access_token).permit(:username, :password)
      end

      def determine_permissions(user_groups)
        yaml_groups = Landable.configuration['ldap'][:permissions]
        permissions_groups = user_groups.select { |group| yaml_groups.include?(group) }

        user_permissions = {}
        permissions_groups.each do |group|
          group_permissions = yaml_groups[group].keys
          group_permissions.each do |perm|
            user_permissions[perm] ||= yaml_groups[group][perm]
          end
        end

        user_permissions
      end
    end
  end
end
