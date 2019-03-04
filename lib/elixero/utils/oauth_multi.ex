defmodule EliXero.Utils.OauthMulti do
  alias EliXero.Client

  def create_auth_header(method, url, additional_params, %Client{} = client) do
    {base_string, oauth_params} = create_oauth_context(method, url, additional_params, client)

    signature = sign(base_string, client)

    "OAuth oauth_signature=\"" <> signature <> "\", " <> EliXero.Utils.Helpers.join_params_keyword(oauth_params, :auth_header)
  end

  defp create_oauth_context(method, url, additional_params, %Client{} = client) do
    timestamp = :erlang.float_to_binary(Float.floor(:os.system_time(:milli_seconds) / 1000), [{:decimals, 0}])

    oauth_signing_params = [
        oauth_consumer_key: client.app_creds.oauth_consumer_key,
        oauth_nonce: EliXero.Utils.Helpers.random_string(10),
        oauth_signature_method: "RSA-SHA1",
        oauth_version: "1.0",
        oauth_timestamp: timestamp
      ]

    params = additional_params ++ oauth_signing_params

    uri_parts = String.split(url, "?")
    url = Enum.at(uri_parts, 0)

    params_with_extras =
      if (length(uri_parts) > 1) do
        query_params = Enum.at(uri_parts, 1) |> URI.decode_query |> Enum.map(fn({key, value}) -> {String.to_atom(key),  URI.encode_www_form(value) |> String.replace("+", "%20") } end)
        params ++ query_params
      else
        params
      end

    params_with_extras = Enum.sort(params_with_extras)

    base_string =
      method <> "&" <>
      URI.encode_www_form(url) <> "&" <>
      URI.encode_www_form(
        EliXero.Utils.Helpers.join_params_keyword(params_with_extras, :base_string)
      )

    {base_string, params}
  end

  def sign(base_string, %Client{} = client) do
    rsa_sha1_sign(base_string, client)
  end

  defp rsa_sha1_sign(base_string, %Client{} = client) do
    hashed = :crypto.hash(:sha, base_string)

    {:ok, body} = File.read client.app_creds.private_key_path

    [decoded_key] = :public_key.pem_decode(body)
    key = :public_key.pem_entry_decode(decoded_key)
    signed = :public_key.encrypt_private(hashed, key)
    URI.encode(Base.encode64(signed), &URI.char_unreserved?(&1))
  end

end
