defmodule Addict.Presenter do
  def strip_all(model, _schema \\ nil), do: Map.take(model, [:id, :role, :pwd_reset_counter])
end