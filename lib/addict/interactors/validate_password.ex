defmodule Addict.Interactors.ValidatePassword do
  def call(changeset, _) do
    changeset
    |> Addict.PasswordValidator.validate()
    |> format_response()
  end

  defp format_response(%{valid?: false, errors: errors}), do: {:error, errors}
  defp format_response(_), do: {:ok, []}
end
