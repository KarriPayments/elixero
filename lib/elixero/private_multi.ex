defmodule EliXero.PrivateMulti do

  def find(client, resource, api_type) do
    url = EliXero.Utils.Urls.api(resource, api_type)

    header = EliXero.Utils.OauthMulti.create_auth_header("GET", url, [oauth_token: client.access_token["oauth_token"]], client)
    EliXero.Utils.HttpMulti.get(url, header, client)
  end

  def find(client, resource, api_type, query_filters, extra_headers) do
    url = EliXero.Utils.Urls.api(resource, api_type) |> EliXero.Utils.Urls.append_query_filters(query_filters)

    header = EliXero.Utils.OauthMulti.create_auth_header("GET", url, [oauth_token: client.access_token["oauth_token"]], client)
    EliXero.Utils.HttpMulti.get(url, header, client, extra_headers)
  end

  def create(client, resource, api_type, data_map) do
    url = EliXero.Utils.Urls.api(resource, api_type)

    method =
      case(api_type) do
        :core -> "PUT"
      end

    header = EliXero.Utils.OauthMulti.create_auth_header(method, url, [oauth_token: client.access_token["oauth_token"]], client)

    case(method) do
      "PUT" -> EliXero.Utils.HttpMulti.put(url, header, client, data_map)
    end
  end

  def update(client, resource, api_type, data_map) do
    url = EliXero.Utils.Urls.api(resource, api_type)

    method =
      case(api_type) do
        :core -> "POST"
      end

    header = EliXero.Utils.OauthMulti.create_auth_header(method, url, [oauth_token: client.access_token["oauth_token"]], client)

    case(method) do
      "POST" -> EliXero.Utils.HttpMulti.post(url, header, client, data_map)
    end
  end

  def delete(client, resource, api_type) do
    url = EliXero.Utils.Urls.api(resource, api_type)

    header = EliXero.Utils.OauthMulti.create_auth_header("DELETE", url, [oauth_token: client.access_token["oauth_token"]], client)

    EliXero.Utils.HttpMulti.delete(url, header, client)
  end

  def upload_multipart(client, resource, api_type, path_to_file, name) do
    url = EliXero.Utils.Urls.api(resource, api_type)

    header = EliXero.Utils.OauthMulti.create_auth_header("POST", url, [oauth_token: client.access_token["oauth_token"]], client)

    EliXero.Utils.HttpMulti.post_multipart(url, header, client, path_to_file, name)
  end

  def upload_attachment(client, resource, api_type, path_to_file, filename, include_online) do
    url = EliXero.Utils.Urls.api(resource, api_type)
    url_for_signing = url <> "/" <> String.replace(filename, " ", "%20") <> "?includeonline=" <> ( if include_online, do: "true", else: "false") # Spaces must be %20 not +
    header = EliXero.Utils.OauthMulti.create_auth_header("POST", url_for_signing, [oauth_token: client.access_token["oauth_token"]], client)

    url = url <> "/" <> URI.encode(filename, &URI.char_unreserved?(&1)) <> "?includeonline=" <> ( if include_online, do: "true", else: "false")
    EliXero.Utils.HttpMulti.post_file(url, header, client, path_to_file)
  end
end