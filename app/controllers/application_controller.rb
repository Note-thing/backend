class ApplicationController < ActionController::API

    # tentative d'authentification d'un utilisateur a partir d'un JWT
    # ce qui est beau, c'est que dans chaque contrôleur où on veut un utilisateur connecté pour y accéder, on fait
    # simplement before_action :authentication et bim, le tour est joué
    def authentication
        token = get_token

        if token.nil?
            raise MissingTokenError
        end

        # assez explicite, on tente de décoder le token et lève une erreur si le token n'est pa valide
        begin
            decode_data = JsonWebToken.decode(token)
        rescue ExceptionHandler::ExpiredSignature => e
            raise InvalidTokenError.new(e)
        rescue ExceptionHandler::DecodeError => e
            raise InvalidTokenError.new(e)
        end

        # on récupère le user_id présent dans le JWT
        user_id = decode_data["user_id"] if decode_data

        begin
            user = User.find(Integer(user_id))
        rescue ActiveRecord::RecordNotFound => e
            raise NotFoundError.new(e.message)
        end

        if user
            # ruby retourne la dernière expression d'une fonction/méthode
            # donc cette ligne est équivalente à return true
            true
        else
            raise InvalidTokenError
        end
    end

    # récupère l'utilisateur connecté, représenté par le modèle User
    def logged_in_user
        token = get_token
        if token.nil?
            return nil
        end
        begin
            decode_data = JsonWebToken.decode(token)
        rescue ExceptionHandler::DecodeError => e
            raise InvalidTokenError.new(e)
        end

        unless decode_data
            return nil
        end

        user_id = decode_data["user_id"] if decode_data

        unless user_id
            return nil
        end

        begin
            user = User.find(user_id)
        rescue ActiveRecord::RecordNotFound => e
            raise NotFoundError.new(e.message)
        end

        user
    end

    # récupère le token qui devrait être préent dans les headers d'une requête
    def get_token
        request.headers["token"]
    end

    # vrai si l'utilisateur est connecté
    def logged_in?
        !!logged_in_user
    end

    # lève une erreur si l'utilisateur n'est pas connecté
    def authorized
        raise MissingTokenError unless logged_in?
    end

    # Ok, alors si une erreur est lancée par un contrôleur ou un modèle, on la catch ici et on renvoie un
    # message JSON qui possède un format bien spécifique
    rescue_from BadRequestError,
                InvalidCredentialsError,
                InvalidInformationError,
                InvalidTokenError,
                MissingTokenError,
                NoJWTSecretError,
                NotFoundError,
                UnprocessableEntityError, with: :render_error_response

    # définit le format des messages d'erreurs renvoyés, en json. le format est le suivant :
    # {
    #     "messages": [
    #         "user not found"
    #     ],
    #     "code": "not_found"
    # }
    # et on ajoute le status http lié aux type d'exception
    def render_error_response(exception)
        render json: { messages: exception.messages , code: exception.code }, status: exception.http_status
    end

end
