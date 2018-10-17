defmodule Addict.PasswordValidator do
  import Ecto.Changeset

  def validate(changeset) do
    changeset
    |> validate_required(:password)
    |> validate_length(:password, min: 5)
  end
end
