defmodule Addict.Interactors.ResetPassword do
  alias Addict.Interactors.{GetUserById, UpdateUserPassword, ValidatePassword}
  require Logger

  def call(params) do
    token = params["token"]
    password = params["password"]
    signature = params["signature"]

    with {:ok} <- validate_params(token, password, signature),
         {:ok, true} <- Addict.Crypto.verify(token, signature),
         {:ok, generation_time, user} <- parse_token(token),
         {:ok} <- validate_generation_time(generation_time),
         {:ok, _} <- validate_password(password),
         {:ok, _} <- UpdateUserPassword.call(user, password),
         do: {:ok, user}
  end

  defp validate_params(token, password, signature) do
    if token == nil || password == nil || signature == nil do
      {:error, [{:params, "Invalid params"}]}
    else
      {:ok}
    end
  end

  def parse_token(token) do
    data = token |> Base.decode16!() |> String.split(",")

    result =
      case data do
        [generation_time, user_id, pwd_reset_counter] ->
          id = String.to_integer(user_id)
          counter = String.to_integer(pwd_reset_counter)
          {:ok, user} = GetUserById.call(id)

          case user do
            %{pwd_reset_counter: ^counter} ->
              {:ok, String.to_integer(generation_time), user}

            _ ->
              :error
          end

        _ ->
          :error
      end

    case result do
      :error ->
        {:error, [{:token, "Password reset token not valid."}]}

      _ ->
        result
    end
  end

  def validate_generation_time(generation_time) do
    time_to_expiry =
      if Addict.Configs.password_reset_token_time_to_expiry() != nil do
        Addict.Configs.password_reset_token_time_to_expiry()
      else
        86_400
      end

    do_validate_generation_time(:erlang.system_time(:seconds) - generation_time <= time_to_expiry)
  end

  defp do_validate_generation_time(true) do
    {:ok}
  end

  defp do_validate_generation_time(false) do
    {:error, [{:token, "Password reset token not valid."}]}
  end

  defp validate_password(password, password_strategies \\ Addict.Configs.password_strategies()) do
    %Addict.PasswordUser{}
    |> Ecto.Changeset.cast(%{password: password}, ~w(password), [])
    |> ValidatePassword.call(password_strategies)
  end
end
